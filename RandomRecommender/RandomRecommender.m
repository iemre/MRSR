% =====================================================================
% This class implements a random recommender that makes random 
% recommendations. It is used to check if a given algorithm performs 
% at least better than a random recommender
% =====================================================================

classdef RandomRecommender < AbstractExperiment
    
    
    properties
        allPredictions
    end
    
    methods (Access = private)
        
        function obj = reconstruct(obj)    
            for userIndex = 1:obj.userCount 
                for itemIndex = 1:obj.itemCount
                    randomRating = obj.minRating + rand() * obj.maxRating;
                    obj.allPredictions(userIndex, itemIndex) = randomRating;
                end
            end
        end
        
        function obj = RandomRecommender(baseSet, testSet)
            obj = obj@AbstractExperiment(baseSet, testSet);
        end
    end
    
    methods (Static)

        function randomRecommender = createNewExperiment(baseSet, testSet)
            randomRecommender = RandomRecommender(baseSet, testSet);
        end

    end

    methods
        function topNList = generateTopNListForUser(obj, n, userIndex)
        end
        function topNList = generateTopNListForTestSetForUser(obj, n, userIndex)
        end
        function prediction = makePrediction(obj, userIndex, itemIndex)
        end
        function initialize(obj)
        end
       
        function obj = calculateErrors(obj)
            totalError = 0;
            totalSquaredError = 0;
            predictionCount = 0;
            
            for userIndex = 1:obj.userCount 
                for itemIndex = 1:obj.itemCount
                    if obj.testSet(userIndex, itemIndex) ~= obj.nilElement
                        trueRating = obj.testSet(userIndex, itemIndex);
                        prediction = obj.minRating + rand() * obj.maxRating;
                        totalError = totalError + abs(prediction-trueRating);
                        predictionCount = predictionCount + 1;
                        totalSquaredError = totalSquaredError + (prediction - trueRating)^2;
                    end
                end
            end
            
            obj.result.setErrorMetrics(obj, totalError, predictionCount);
            obj.result.setRMSE(totalSquaredError, predictionCount);
            disp(obj.result);
        end
       
        
        function obj = calculateTopNHitRate(obj, n)
            tic
            
            obj.reconstruct();
            hit = 0;
            predictionCount = 0;
            
            for userIndex = 1:obj.userCount               
                if UIMatrixUtils.userHasNoRatings(obj.testSet, userIndex, obj.nilElement)
                    continue;
                end
               
                predictionCount = predictionCount + ...
                                 UIMatrixUtils.getNumberOfRatingsOfUser...
                                 (obj.testSet, userIndex, obj.nilElement);
                             
                predictedUserRatings = obj.allPredictions(userIndex, :); 

                % filter out already given ratings
                predictedUserRatings = UIMatrixUtils.filterGivenRatingsOfUser( ...
                        userIndex, predictedUserRatings, obj.baseSet, obj.nilElement);

                [~, topNIndexes] = UIMatrixUtils.getSortedTopNListOfPredictions(n,predictedUserRatings);

                for ratingIndex = topNIndexes
                    if UIMatrixUtils.userHasRatedItem(obj.testSet, userIndex, ratingIndex, obj.nilElement)
                        hit = hit + 1;
                    end
                end
                
            end
            
            hit
            predictionCount
            hitRate = hit/predictionCount;
            obj.result.hitRate = hitRate
            fprintf('\n\n*** HitRate = %f\n', obj.result.hitRate);
            toc
        end
        
    end
end