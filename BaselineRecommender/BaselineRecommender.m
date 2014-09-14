% This class implements a simple baseline recommender

classdef BaselineRecommender < AbstractExperiment
    
    properties
    end
    
    methods (Access = private)
        function obj = BaselineRecommender(baseSet, testSet)
            obj = obj@AbstractExperiment(baseSet, testSet);
        end
    end
    
    
    methods (Static)
        function recom = createNew(baseSet, testSet)
            recom = BaselineRecommender(baseSet,testSet);
        end
    end
    
    
    methods
        function topNList = generateTopNListForUser(obj, n, userIndex)
            % not implemented
        end
        function topNList = generateTopNListForTestSetForUser(obj, n, userIndex)
            % not implemented
        end
        function prediction = calculateFullPrediction(obj, userIndex, itemIndex)
            % not implemented
        end
        function initialiseForCPP(obj)
            % not implemented
        end
       
        function obj = calculateErrorByUserAverage(obj)
            totalError = 0;
            totalPrediction = 0;
            totalSquaredError = 0;
            
            for userIndex = 1:obj.userCount
                if mod(userIndex, 100) == 0
                    fprintf('Processing user %d\n', userIndex);
                end
                ratingIndexes = obj.baseSet(userIndex, :) ~= obj.nilElement;
                userAverage = mean(obj.baseSet(userIndex, ratingIndexes));
                
                for itemIndex = 1:obj.itemCount
                    if UIMatrixUtils.userHasNotRatedItem(obj.testSet, userIndex, itemIndex, obj.nilElement)
                        continue;
                    end
                    
                    trueRating = obj.testSet(userIndex, itemIndex);
                    totalError = totalError + abs(userAverage - trueRating);
                    totalSquaredError = totalSquaredError + (userAverage-trueRating)^2;
                    totalPrediction = totalPrediction + 1;
                end
            end
            
            obj.result.setErrorMetrics(obj, totalError, totalPrediction);
            obj.result.setRMSE(totalSquaredError, totalPrediction);
            obj.result
        end
       
        
        function obj = calculateErrorByItemAverage(obj)
            totalError = 0;
            totalPrediction = 0;
            totalSquaredError = 0;
            
            for itemIndex = 1:obj.itemCount
                if mod(itemIndex, 100) == 0
                    fprintf('Processing item %d\n', itemIndex);
                end
                ratingIndexes = obj.baseSet(:, itemIndex) ~= obj.nilElement;
                itemAverage = mean(obj.baseSet(ratingIndexes, itemIndex));
                
                for userIndex = 1:obj.userCount
                    if UIMatrixUtils.userHasNotRatedItem(obj.testSet, userIndex, itemIndex, obj.nilElement)
                        continue;
                    end
                    if isnan(itemAverage)
                        obj.nanPrediction = obj.nanPrediction + 1;
                        continue;
                    end
                    trueRating = obj.testSet(userIndex, itemIndex);
                    totalError = totalError + abs(itemAverage - trueRating);
                    totalSquaredError = totalSquaredError + (itemAverage-trueRating)^2;
                    totalPrediction = totalPrediction + 1;
                end
            end
            
            obj.result.setErrorMetrics(obj, totalError, totalPrediction);
            obj.result.setRMSE(totalSquaredError, totalPrediction);
            obj.result
        end
       
        function [itemIndices, hits] = getTopHitItems(obj, data)
            % Returns the most hit (picked) item indices and the number of
            % hits (picks)
                                                    
            missingRatingsOfItems = sum(data(:,:) == obj.nilElement);
            [sortedMissingRatings,itemIndices] = sort(missingRatingsOfItems);
            hits = ones(1, obj.itemCount)*obj.userCount - sortedMissingRatings;
            
        end
    
        function cpp = calculateCPPByMaxF(obj)
            [topHitItemIndices, ~] = obj.getTopHitItems(obj.baseSet);
            allData = UIMatrixUtils.mergeBaseAndTestSet(obj.baseSet, obj.testSet, obj.nilElement);
            
            totalCpp = 0;
            for userIndex = 1:obj.userCount
                correctlyPlacedCount = 0;
                fprintf('processing user %d\n', userIndex);
                itemsUserHasNotRated = find(allData(userIndex, :) == obj.nilElement);
                
                for i = 1:obj.itemCount-1
                    if UIMatrixUtils.userHasRatedItem(obj.testSet, userIndex, topHitItemIndices(i), obj.nilElement)
                        members = ismember((i+1):obj.itemCount, itemsUserHasNotRated);
                        correctlyPlacedCount = correctlyPlacedCount + sum(members);
                    end
                end      
                
                userTestRatingCount = UIMatrixUtils.getNumberOfRatingsOfUser(obj.testSet, userIndex, obj.nilElement);
                userAllRatingCount = UIMatrixUtils.getNumberOfRatingsOfUser(allData, userIndex, obj.nilElement);
                
                totalCpp = totalCpp + correctlyPlacedCount/(userTestRatingCount*(obj.itemCount-userAllRatingCount));
            end
            
            cpp = totalCpp / obj.userCount;
            disp(cpp);
        end
                
    end
    
end

