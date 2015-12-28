% ========================================================================
% ItemBasedSparseCoderExperiment contains the methods to run an item-based 
% sparse coding recommender (both predictive and top-n)
% User-Item Matrix Assumption: Columns represent items, and rows
% represent users.
% ========================================================================

classdef ItemBasedSparseCoderExperiment < AbstractSparseCoderExperiment
    properties
    end
    
    methods (Access = private)
        
        function obj = ItemBasedSparseCoderExperiment(baseSet, testSet)
            obj = obj@AbstractSparseCoderExperiment(baseSet, testSet);
        end
        
        function prediction = predictRating(obj, dictionary, userIndex, itemRepresentation)
            % predicts the given user's rating on item whose sparse
            % representation is given as the parameter sparseRepresentation
            
            if length(dictionary(userIndex,:)) ~= length(itemRepresentation)
                error('Vector lengths must match');
            end
            
            nonzeros = find(dictionary(userIndex,:) ~= obj.nilElement);
            prediction = (dictionary(userIndex, nonzeros) * itemRepresentation(nonzeros)')/sum(itemRepresentation(nonzeros));
            if isnan(prediction)
                prediction = obj.nilElement;
                obj.nanPrediction = obj.nanPrediction + 1;
            end
        end
        
        function prediction = predictRatingFromBase(obj, userIndex, itemRepresentation)
            if length(obj.baseSet(userIndex,:)) ~= length(itemRepresentation)
                error('Vector lengths must match');
            end
            
            nonzeros = find(obj.baseSet(userIndex,:) ~= obj.nilElement);
            prediction = (obj.baseSet(userIndex, nonzeros) * itemRepresentation(nonzeros)')/sum(itemRepresentation(nonzeros));
        end
        
        function result = getSparseRepresentationForItem(obj, dictionary, itemIndex)
            item = dictionary(:, itemIndex);
            dictionary(:, itemIndex) = zeros(length(item), 1);
            result = SparseCoder.solveWithSolver(obj.solver, dictionary, item);
        end
        
    end
    
    
    methods (Static)
        
        function sparseCoder = createItemBasedExperiment(baseSet, testSet)
            sparseCoder = ItemBasedSparseCoderExperiment(baseSet, testSet);
            sparseCoder.solver = SparseCoder.PCBC;
            sparseCoder.nanPrediction = 0;
        end
        
    end

    
    methods
        
        function initialize(obj)
            if isempty(obj.sparseRepresentation)
                obj.reconstructWithoutNormalisation;
            end
        end
        
        function dictionary = normaliseDictionary(obj, dictionary)
            [~, colCount] = size(dictionary);
            for itemIndex = 1:colCount
                dictionary(:, itemIndex) = dictionary(:, itemIndex)./sum(abs(dictionary(:,itemIndex)));   
            end
        end
        
        function dictionary = removeUsersNotHavingRatingForItem(obj, dictionary, itemIndex)
            userIndices = dictionary(:, itemIndex) == obj.nilElement;
            dictionary(userIndices, :) = []; 
        end
        
        function [dictionary, remainingColumns] = removeColumnsNotHavingRatingForUser(obj, dictionary, userIndex, activeItemIndex)
            columnIndices = dictionary(userIndex, :) == obj.nilElement;
            if columnIndices(activeItemIndex) == 1
                columnIndices(activeItemIndex) = 0;
            end
            
            remainingColumns = [];
            
            for i = 1:length(dictionary(userIndex, :))
                if dictionary(userIndex, i) ~= obj.nilElement || i == activeItemIndex
                    remainingColumns = [remainingColumns i];
                end
            end
            
            dictionary(:, columnIndices) = [];
        end
              
        function result = userHasNotRatedItemInTestingSet(obj, userIndex, itemIndex)
            result = UIMatrixUtils.userHasNotRatedItem(obj.testSet,userIndex,itemIndex,obj.nilElement);
        end
        
        function obj = initialiseReconstruction(obj)
            obj.reconstruction = zeros(obj.userCount, obj.itemCount);
        end     
                
        function obj = calculateSparseRepresentation(obj, dataSet)
            for testItemIndex = 1:obj.itemCount
                dictionary = dataSet; 
                item = dictionary(:, testItemIndex);
                fprintf('Reconstructing item %d\n', testItemIndex);
                dictionary(:, testItemIndex) = zeros(length(item), 1);
                try
                    wj = SparseCoder.solveWithSolver(obj.solver, dictionary, item);
                    obj.sparseRepresentation(:, testItemIndex) = wj;
                catch err
                    fprintf('Error ignored:\n');
                    disp(err);
                    continue;
                end
            end
        end
        
        function obj = reconstructWithoutNormalisation(obj)
            for itemIndex = 1:obj.itemCount    
                dictionary = obj.baseSet;
                fprintf('Reconstructing item %d\n', itemIndex);
                try
                    wj = obj.getSparseRepresentationForItem(dictionary, itemIndex);
                    obj.sparseRepresentation(:, itemIndex) = wj;
                    obj.reconstruction(:, itemIndex) = obj.baseSet * wj;
                catch err
                    fprintf('Error ignored:\n');
                    disp(err);
                    continue;
                end
            end
        end
        
        function obj = reconstructAll(obj)
            obj.nanPrediction = 0;
            obj.reconstruction = ones(obj.userCount, obj.itemCount) * obj.nilElement;
            
            for itemIndex = 1:obj.itemCount
                fprintf('Processing item %d\n', itemIndex);
                dictionary = obj.baseSet;
                try
                    itemRep = obj.getSparseRepresentationForItem(dictionary, itemIndex);
                catch err
                    disp(err);
                    obj.nanPrediction = obj.nanPrediction + 1;
                    continue;
                end
                for userIndex = 1:obj.userCount
                    prediction = obj.predictRatingFromBase(userIndex, itemRep');
                    
                    if isnan(prediction)
                        obj.nanPrediction = obj.nanPrediction + 1;
                        continue;
                    end
                    
                    obj.reconstruction(userIndex, itemIndex) = prediction;
                end
            end
            
        end
        
        function obj = reconstructOnlyTestSet(obj)
            obj.nanPrediction = 0;
            
            for itemIndex = 1:obj.itemCount
                fprintf('Reconstructing item %d\n', itemIndex);
                dictionary = obj.getDictionaryForColumn(itemIndex);
                item = obj.baseSet(:, itemIndex);
                try
                    wj = SparseCoder.solveWithSolver(obj.solver, dictionary, item);
                catch err
                    fprintf('Sparse coder-related error ignored:\n');
                    disp(err);
                    continue;
                end
                
                for user = 1:obj.userCount
                    if obj.testSet(user, itemIndex) == obj.nilElement
                        continue;
                    end

                    predictedRating = obj.predictRating(dictionary, user, wj');

                    if isnan(predictedRating)
                        fprintf('User rating could not be predicted (User #%d - Item #%d)\n', user, itemIndex); 
                    end

                    obj.reconstruction(user, itemIndex) = predictedRating;
                end 
            end
        end
        
        function obj = reconstructAllByRemovalOfRows(obj)
            obj.nanPrediction = 0;
            
            for itemIndex = 1:obj.itemCount
                fprintf('Reconstructing item %d\n', itemIndex);
                dictionary = obj.getDictionaryForColumn(itemIndex);
                usersToRemove = [];
                for user = 1:obj.userCount
                    if UIMatrixUtils.userHasNotRatedItem(obj.baseSet, user, itemIndex, obj.nilElement)
                        usersToRemove = [usersToRemove user];
                    end
                end
                
                dictionary(usersToRemove, :) = [];
                item = obj.baseSet(:, itemIndex);
                item(usersToRemove) = [];
                
                try
                    wj = SparseCoder.solveWithSolver(obj.solver, dictionary, item);
                catch err
                    warning('Sparse coder-related error ignored:');
                    disp(err);
                    continue;
                end
                
                wj = wj';% UIMatrixUtils.normaliseVector(wj, obj.nilElement);
                
                
                for user = 1:obj.userCount
                    predictedRating = obj.predictRating(obj.baseSet, user, wj);
                    
                    if isnan(predictedRating)
                        predictedRating = 0;
                        fprintf('User rating could not be predicted (User #%d - Item #%d)\n', user, itemIndex); 
                    end
                    
                    obj.reconstruction(user, itemIndex) = predictedRating;
                end 
            end            
        end
        
        function obj = reconstructTestByRemovalOfRows(obj)
            obj.nanPrediction = 0;
            
            for itemIndex = 1:obj.itemCount
                fprintf('Reconstructing item %d\n', itemIndex);
                dictionary = obj.getDictionaryForColumn(itemIndex);
                usersToRemove = [];
                for user = 1:obj.userCount
                    if UIMatrixUtils.userHasNotRatedItem(obj.baseSet, user, itemIndex, obj.nilElement)
                        usersToRemove = [usersToRemove user];
                    end
                end
                
                dictionary(usersToRemove, :) = [];
                item = obj.baseSet(:, itemIndex);
                item(usersToRemove) = [];
                
                try
                    wj = SparseCoder.solveWithSolver(obj.solver, dictionary, item);
                catch err
                    warning('Sparse coder-related error ignored:');
                    disp(err);
                    continue;
                end
                
                for user = 1:obj.userCount
                    if obj.testSet(user, itemIndex) == obj.nilElement
                        continue;
                    end
                    
                    predictedRating = obj.predictRating(obj.baseSet, user, wj');
                    
                    if isnan(predictedRating)
                        warning('User rating could not be predicted (User #%d - Item #%d)\n', user, itemIndex); 
                    end
                    
                    obj.reconstruction(user, itemIndex) = predictedRating;
                end 
            end
        end
        
        function novelty = calculateNovelty(obj, recons, n)
            if recons
                obj.reconstructWithoutNormalisation;
            end
            
            itemRatingCount = zeros(1, obj.itemCount);
            
            for i = 1:obj.itemCount
                ratings = obj.baseSet(:, i) ~= obj.nilElement;
                totalRatings = sum(ratings);
                itemRatingCount(i) = totalRatings;
            end
            
            fprintf('finished calculating total ratings of items\n');
            
            totalNovelty = 0;
            
            for userIndex = 1:obj.userCount
                fprintf('processing user %d\n', userIndex);
                userRatings = obj.reconstruction(userIndex, :);
                
                [~, topItemIndices] = sort(userRatings, 'descend');
                topItemIndices = topItemIndices(1:n);
                total = 0;
                for i = 1:n
                    total = total + log2(obj.userCount/itemRatingCount(topItemIndices(i)));
                end
                totalNovelty = totalNovelty + total;
            end
            
            novelty = totalNovelty/obj.userCount;
            disp(novelty);
        end
        
        function obj = calculateErrorWithoutReconstruction(obj)
            totalError = 0;
            predictionCount = 0;
            totalSquaredError = 0;
            
            for testItemIndex = 1:obj.itemCount
                
                for userIndex = 1:obj.userCount
                    if obj.testSet(userIndex, testItemIndex) == obj.nilElement
                        continue;
                    end
                    
                    prediction = obj.reconstruction(userIndex, testItemIndex);
                    
                    if isnan(prediction)
                        warning('Prediction not available for User #%d - Item #%d', userIndex, testItemIndex); 
                        continue;
                    end
                    trueRating = obj.testSet(userIndex, testItemIndex);
                    
                    % defensively check for mistakes
                    if trueRating == obj.nilElement 
                        error('True rating cannot be equal to the nil element! Complete revision needed.');
                    end
                    
                    totalError = totalError + abs(prediction-trueRating);
                    totalSquaredError = totalSquaredError + (prediction - trueRating)^2;
                    predictionCount = predictionCount + 1;
                end
                    
            end
            
            obj.result.setErrorMetrics(obj, totalError, predictionCount);
            obj.result.setRMSE(totalSquaredError, predictionCount);
            obj.result    
        end
        
        function topNList = generateTopNListForUser(obj, n, userIndex)
            if isempty(obj.reconstruction)
                obj.reconstructWithoutNormalisation;
            end
            
            predictions = obj.reconstruction(userIndex, :);
            [~, topNList] = sort(predictions, 'descend');
            topNList = topNList(1:n);
        end
        
        function obj = calculateSimpleSparseItemReconstructionError(obj)
            obj.reconstructOnlyTestSet();
            obj.calculateErrorWithoutReconstruction();
        end
        
        function obj = calculateErrorByRowRemoval(obj)
            obj.reconstructTestByRemovalOfRows();
            obj.calculateErrorWithoutReconstruction();
        end
        
        function obj = calculateErrorByColumnRemoval(obj)
            totalError = 0;
            totalSquaredError = 0;
            totalPrediction = 0;
            obj.nanPrediction = 0;                        
            
            for itemIndex = 1:obj.itemCount
                fprintf('Processing item %d\n', itemIndex);
                
                for userIndex = 1:obj.userCount
                    if obj.userHasNotRatedItemInTestingSet(userIndex, itemIndex)
                        continue;
                    end
                    
                    dictionary = obj.baseSet;
                    [dictionary, selectedColumns] = obj.removeColumnsNotHavingRatingForUser(dictionary, userIndex, itemIndex);
                    % dictionary = obj.normaliseDictionary(dictionary);
                    dictionaryItemIndex = find(selectedColumns == itemIndex);
                    try
                        itemRep = obj.getSparseRepresentationForItem(dictionary, dictionaryItemIndex);
                    catch err
                        disp(err);
                        obj.nanPrediction = obj.nanPrediction + 1;
                        continue;
                    end
                    paddedItemRep = ones(1, obj.itemCount) * obj.nilElement;
                    paddedItemRep(selectedColumns) = itemRep;
                    prediction = obj.predictRatingFromBase(userIndex, paddedItemRep);
                    
                    if isnan(prediction)
                        obj.nanPrediction = obj.nanPrediction + 1;
                        continue;
                    end
                    trueRating = obj.testSet(userIndex, itemIndex);
                    totalError = totalError + abs(trueRating-prediction);
                    totalSquaredError = totalSquaredError + (trueRating-prediction)^2;
                    totalPrediction = totalPrediction + 1;
                end
                
                mae = totalError / totalPrediction
            end
            
            obj.result.setErrorMetrics(obj, totalError, totalPrediction);
            obj.result.setRMSE(totalSquaredError, totalPrediction);
            obj.result
        end
        
        function obj = calculateErrorByNormalisedColumnRemoval(obj)
            totalError = 0;
            totalSquaredError = 0;
            totalPrediction = 0;
            obj.nanPrediction = 0;                        
            
            for itemIndex = 1:obj.itemCount
                fprintf('Processing item %d\n', itemIndex);
                
                for userIndex = 1:obj.userCount
                    if obj.userHasNotRatedItemInTestingSet(userIndex, itemIndex)
                        continue;
                    end
                    
                    dictionary = obj.baseSet;
                    [dictionary, selectedColumns] = obj.removeColumnsNotHavingRatingForUser(dictionary, userIndex, itemIndex);
                    dictionary = obj.normaliseDictionary(dictionary);
                    dictionaryItemIndex = find(selectedColumns == itemIndex);
                    try
                        itemRep = obj.getSparseRepresentationForItem(dictionary, dictionaryItemIndex);
                    catch err
                        disp(err);
                        obj.nanPrediction = obj.nanPrediction + 1;
                        continue;
                    end
                    paddedItemRep = ones(1, obj.itemCount) * obj.nilElement;
                    paddedItemRep(selectedColumns) = itemRep;
                    prediction = obj.predictRatingFromBase(userIndex, paddedItemRep);
                    
                    if isnan(prediction)
                        obj.nanPrediction = obj.nanPrediction + 1;
                        continue;
                    end
                    trueRating = obj.testSet(userIndex, itemIndex);
                    totalError = totalError + abs(trueRating-prediction);
                    totalSquaredError = totalSquaredError + (trueRating-prediction)^2;
                    totalPrediction = totalPrediction + 1;
                end
                
                mae = totalError / totalPrediction
            end
            
            obj.result.setErrorMetrics(obj, totalError, totalPrediction);
            obj.result.setRMSE(totalSquaredError, totalPrediction);
            obj.result
          end
        
        function obj = calculateErrorByColumnAndRowRemoval(obj)
            totalError = 0;
            totalSquaredError = 0;
            totalPrediction = 0;
            obj.nanPrediction = 0;
            
            for itemIndex = 1:obj.itemCount
                fprintf('Processing item %d\n', itemIndex);
                
                for userIndex = 1:obj.userCount
                    if obj.userHasNotRatedItemInTestingSet(userIndex, itemIndex)
                        continue;
                    end
                    
                    dictionary = obj.baseSet;
                    [dictionary, selectedColumns] = obj.removeColumnsNotHavingRatingForUser(dictionary, userIndex, itemIndex);
                    dictionaryItemIndex = find(selectedColumns == itemIndex);
                    dictionary = obj.removeUsersNotHavingRatingForItem(dictionary, dictionaryItemIndex);
                    try
                        itemRep = obj.getSparseRepresentationForItem(dictionary, dictionaryItemIndex);
                    catch err
                        disp(err);
                        obj.nanPrediction = obj.nanPrediction + 1;
                        continue;
                    end
                    paddedItemRep = ones(1, obj.itemCount) * obj.nilElement;
                    paddedItemRep(selectedColumns) = itemRep;
                    prediction = obj.predictRatingFromBase(userIndex, paddedItemRep);
                    
                    if isnan(prediction)
                        obj.nanPrediction = obj.nanPrediction + 1;
                        continue;
                    end
                    trueRating = obj.testSet(userIndex, itemIndex);
                    totalError = totalError + abs(trueRating-prediction);
                    totalSquaredError = totalSquaredError + (trueRating-prediction)^2;
                    totalPrediction = totalPrediction + 1;
                end
                
                mae = totalError / totalPrediction
            end
            
            obj.result.setErrorMetrics(obj, totalError, totalPrediction);
            obj.result.setRMSE(totalSquaredError, totalPrediction);
            obj.result
        end
        
        function topNList = generateTopNListForTestSetForUser(obj, n, userIndex)
            if isempty(obj.reconstruction)
                obj.reconstructWithoutNormalisation;
            end
            
            ratings = obj.reconstruction(userIndex, :);
            [~, topList] = sort(ratings, 'descend');
            topNList = [];
            k = 1;
            for itemIndex = topList
                if UIMatrixUtils.userHasRatedItem(obj.baseSet,userIndex,itemIndex,obj.nilElement)
                    continue;
                end
                topNList(k) = itemIndex;
                k = k + 1;
                if k > n
                    break;
                end
            end
        end
        
        function prediction = makePrediction(obj, userIndex, itemIndex)
            dictionary = obj.baseSet;
            [dictionary, selectedColumns] = obj.removeColumnsNotHavingRatingForUser(dictionary, userIndex, itemIndex);
            dictionaryItemIndex = find(selectedColumns == itemIndex);
            % dictionary = obj.removeUsersNotHavingRatingForItem(dictionary, dictionaryItemIndex);
            try
                itemRep = obj.getSparseRepresentationForItem(dictionary, dictionaryItemIndex);
            catch err
                disp(err)
                prediction = 0;
                return;
            end
            paddedItemRep = ones(1, obj.itemCount) * obj.nilElement;
            paddedItemRep(selectedColumns) = itemRep;
            prediction = obj.predictRatingFromBase(userIndex, paddedItemRep);
        end
    end
    
end

