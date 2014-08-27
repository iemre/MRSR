% ========================================================================
% UserBasedSparseCoderExperiment contains the methods to run a user-based 
% sparse coding recommender. 
% User-Item Matrix Assumption: Columns represent users, and rows
% represent items.
% ========================================================================
classdef UserBasedSparseCoderExperiment < AbstractSparseCoderExperiment
    properties
    end
    
    methods (Access = private)
    
        function obj = UserBasedSparseCoderExperiment(baseSet, testSet)
            obj = obj@AbstractSparseCoderExperiment(baseSet, testSet);
        end
          
        function result = getSparseRepresentationForUser(obj, dictionary, userIndex)
            user = dictionary(:, userIndex);
            dictionary(:, userIndex) = zeros(length(user), 1);
            result = SparseCoder.solveWithSolver(obj.solver, dictionary, user);
        end
        
        function result = predictRating(obj, itemIndex, userRepresentation)
            if length(obj.baseSet(itemIndex, :)) ~= length(userRepresentation)
                error('Vector sizes must be equal');
            end
            
            ratingIndices = obj.baseSet(itemIndex, :) ~= obj.nilElement;
            nominator = obj.baseSet(itemIndex, ratingIndices) * userRepresentation(ratingIndices);
            userRepresentation(ratingIndices);
            denominator = sum(userRepresentation(ratingIndices));
            result = nominator/denominator;
        end
        
    end
    
    
    methods (Static)
        
        function sparseCoder = createUserBasedExperiment(baseSet, testSet)
            sparseCoder = UserBasedSparseCoderExperiment(baseSet', testSet');
            sparseCoder.solver = SparseCoder.PCBC;
            [sparseCoder.userCount, sparseCoder.itemCount] = deal(sparseCoder.itemCount, sparseCoder.userCount);
        end
        
    end

    
    methods
        function result = userHasNotRatedItemInTestingSet(obj, userIndex, itemIndex)
            result = UIMatrixUtils.userHasNotRatedItem(obj.testSet',userIndex,itemIndex,obj.nilElement);
        end
              
        function obj = initialiseReconstruction(obj)
            obj.reconstruction = zeros(obj.userCount, obj.itemCount);
        end     
                
        function dictionary = removeItemsNotRatedByUser(obj, dictionary, userIndex)
            itemIndices = dictionary(:, userIndex) == obj.nilElement;
            dictionary(itemIndices, :) = []; 
        end
        
        function [dictionary, remainingColumns] = removeColumnsNotHavingItemRating(obj, dictionary, itemIndex, userIndex)
            columnIndices = dictionary(itemIndex, :) == obj.nilElement;
            if columnIndices(userIndex) == 1
                columnIndices(userIndex) = 0;
            end
            remainingColumns = [];
            
            for i = 1:length(dictionary(itemIndex, :))
                if dictionary(itemIndex, i) ~= obj.nilElement || i == userIndex
                    remainingColumns = [remainingColumns i];
                end
            end
            
            dictionary(:, columnIndices) = [];
        end
        
        function obj = calculateErrorByRowRemoval(obj)
            totalError = 0;
            totalSquaredError = 0;
            totalPrediction = 0;
            
            for userIndex = 1:obj.userCount
                fprintf('Processing user %d\n', userIndex);
                dictionary = obj.baseSet;
                dictionary = obj.removeItemsNotRatedByUser(dictionary, userIndex);
                userRep = obj.getSparseRepresentationForUser(dictionary, userIndex);
                for itemIndex = 1:obj.itemCount
                    if obj.userHasNotRatedItemInTestingSet(userIndex, itemIndex)
                        continue;
                    end
                    
                    prediction = obj.predictRating(itemIndex, userRep);
                    if isnan(prediction)
                        obj.nanPrediction = obj.nanPrediction + 1;
                        continue;
                    end
                    trueRating = obj.testSet(itemIndex, userIndex);
                    totalError = totalError + abs(prediction - trueRating);
                    totalSquaredError = totalSquaredError + (prediction - trueRating)^2;
                    totalPrediction = totalPrediction + 1;
                end
                mae = totalError/totalPrediction
            end
            
            obj.result.setErrorMetrics(obj, totalError, totalPrediction);
            obj.result.setRMSE(totalSquaredError, totalPrediction);
            obj.result
        end
        
        function obj = calculateErrorByColumnRemoval(obj)
            totalError = 0;
            totalSquaredError = 0;
            totalPrediction = 0;
            
            for userIndex = 1:obj.userCount
                fprintf('Processing user %d\n', userIndex);
                
                for itemIndex = 1:obj.itemCount
                    if obj.userHasNotRatedItemInTestingSet(userIndex, itemIndex)
                        continue;
                    end
                    
                    dictionary = obj.baseSet;
                    [dictionary, selectedColumns] = obj.removeColumnsNotHavingItemRating(dictionary, itemIndex, userIndex);
                    userIndexForDictionary = find(selectedColumns == userIndex);
                    userRep = obj.getSparseRepresentationForUser(dictionary, userIndexForDictionary);
                    paddedUserRep = ones(1, obj.userCount) * obj.nilElement;
                    paddedUserRep(selectedColumns) = userRep;
                    prediction = obj.predictRating(itemIndex, paddedUserRep');
                    
                    if isnan(prediction)
                        obj.nanPrediction = obj.nanPrediction + 1;
                        continue;
                    end
                    
                    trueRating = obj.testSet(itemIndex, userIndex);
                    totalError = totalError + abs(prediction - trueRating);
                    totalSquaredError = totalSquaredError + (prediction - trueRating)^2;
                    totalPrediction = totalPrediction + 1;
                end
                
                mae = totalError/totalPrediction
            end
            
            obj.result.setErrorMetrics(obj, totalError, totalPrediction);
            obj.result.setRMSE(totalSquaredError, totalPrediction);
            obj.result
        end
        
        function obj = calculateErrorByRowAndColumnRemoval(obj)
            totalError = 0;
            totalSquaredError = 0;
            totalPrediction = 0;
            
            for userIndex = 1:obj.userCount
                fprintf('Processing user %d\n', userIndex);
                
                for itemIndex = 1:obj.itemCount
                    if obj.userHasNotRatedItemInTestingSet(userIndex, itemIndex)
                        continue;
                    end
                    
                    dictionary = obj.baseSet;
                    [dictionary, selectedColumns] = obj.removeColumnsNotHavingItemRating(dictionary, itemIndex, userIndex);
                    userIndexForDictionary = find(selectedColumns == userIndex);
                    dictionary = obj.removeItemsNotRatedByUser(dictionary, userIndexForDictionary);
                    
                    userRep = obj.getSparseRepresentationForUser(dictionary, userIndexForDictionary);
                    paddedUserRep = ones(1, obj.userCount) * obj.nilElement;
                    paddedUserRep(selectedColumns) = userRep;
                    prediction = obj.predictRating(itemIndex, paddedUserRep');
                    
                    if isnan(prediction)
                        obj.nanPrediction = obj.nanPrediction + 1;
                        continue;
                    end
                    
                    trueRating = obj.testSet(itemIndex, userIndex);
                    totalError = totalError + abs(prediction - trueRating);
                    totalSquaredError = totalSquaredError + (prediction - trueRating)^2;
                    totalPrediction = totalPrediction + 1;
                end
                
                mae = totalError/totalPrediction
            end
            
            obj.result.setErrorMetrics(obj, totalError, totalPrediction);
            obj.result.setRMSE(totalSquaredError, totalPrediction);
            obj.result
        end
    
        function obj = calculateErrorBySimpleWeightedAverage(obj)
            obj.nanPrediction = 0;
            totalError = 0;
            totalSquaredError = 0;
            totalPrediction = 0;
            
            for userIndex = 1:obj.userCount
                fprintf('Processing user %d\n', userIndex);
                dictionary = obj.baseSet;
                userRep = obj.getSparseRepresentationForUser(dictionary, userIndex);
                for itemIndex = 1:obj.itemCount
                    if obj.userHasNotRatedItemInTestingSet(userIndex, itemIndex)
                        continue;
                    end
                    
                    prediction = obj.predictRating(itemIndex, userRep);
                    if isnan(prediction)
                        obj.nanPrediction = obj.nanPrediction + 1;
                        continue;
                    end
                    trueRating = obj.testSet(itemIndex, userIndex);
                    totalError = totalError + abs(prediction - trueRating);
                    totalSquaredError = totalSquaredError + (prediction - trueRating)^2;
                    totalPrediction = totalPrediction + 1;
                end
                mae = totalError/totalPrediction
            end
            
            obj.result.setErrorMetrics(obj, totalError, totalPrediction);
            obj.result.setRMSE(totalSquaredError, totalPrediction);
            obj.result            
        end
        
        
        
        function topNList = generateTopNListForUser(obj, n, userIndex)
            % will not be implemented
        end
        function topNList = generateTopNListForTestSetForUser(obj, n, userIndex)
            % will not be implemented
        end
        function prediction = calculateFullPrediction(obj, userIndex, itemIndex);
            % will not be implemented
        end
        
    end
       
end

