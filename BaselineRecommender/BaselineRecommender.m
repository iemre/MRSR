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
        function prediction = makePrediction(obj, userIndex, itemIndex)
            % not implemented
        end
        function initialize(obj)
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
                
    end
    
end

