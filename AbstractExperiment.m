% =====================================================================
% AbstractExperiment contains some methods and properties common to all
% experiments. 
%
% All experiment classes inherit this AbstractExperiment class.
% =====================================================================
classdef (Abstract) AbstractExperiment < handle
   properties
       result
       baseSet
       testSet
       userCount
       itemCount
       nilElement = 0
       lastTotalError = 0
       lastPredictionCount = 0
       minRating
       maxRating
       nanPrediction = 0
   end
   
   methods (Abstract)
       topNList = generateTopNListForUser(obj, n, userIndex)
       topNList = generateTopNListForTestSetForUser(obj, n, userIndex)
       prediction = calculateFullPrediction(obj, userIndex, itemIndex);
   end
   
   methods
       
       function obj = AbstractExperiment(baseSet, testSet)
           obj.baseSet = baseSet;
           obj.testSet = testSet;
           obj.nilElement = 0;
           obj.nanPrediction = 0;
           obj.result = Result;
           obj.result.nilElement = obj.nilElement;
           obj.minRating = min([min(baseSet(baseSet ~= obj.nilElement)), min(testSet(testSet ~= obj.nilElement))]);
           obj.maxRating = max([max(baseSet(baseSet ~= obj.nilElement)), max(testSet(testSet ~= obj.nilElement))]);
           obj.setupSizes();
       end
       
       function setupSizes(obj)
           minSize = min(size(obj.testSet), size(obj.baseSet));
           obj.userCount = minSize(1);
           obj.itemCount = minSize(2);
       end
       
       
        function obj = showTopNCoverage(obj, n, userIndices)
            obj.result.resetItemHits(obj.itemCount);
            i = 1;
            for userIndex = userIndices
                fprintf('Iteration %d\n', i);
                topNList = obj.generateTopNListForUser(n, userIndex);
                obj.result.increaseItemHitsInList(topNList);
                i = i + 1;
            end
            
            obj.result.setCoverageRate();
            figure, bar(obj.result.itemHits)
        end
        
        function obj = showPrecisionAndRecall(obj, n, userIndices)
            obj.result.resetItemHits(obj.itemCount);
            i = 1;
            totalCount = 0;
            totalPrecision = 0;
            totalRecall = 0;
            totalHit = 0;
            for userIndex = userIndices
                if UIMatrixUtils.userHasNoRatings(obj.testSet, userIndex, obj.nilElement)
                    continue;
                end

                hit = 0;
                fprintf('Iteration %d\n', i);
                topNList = obj.generateTopNListForTestSetForUser(n, userIndex);
                obj.result.increaseItemHitsInList(topNList);
                i = i + 1;
                
                for itemIndex = topNList
                    if UIMatrixUtils.userHasRatedItem(obj.testSet, userIndex, itemIndex, obj.nilElement)
                        hit = hit + 1;
                    end
                end
                totalHit = totalHit + hit;
                precision = hit/n;
                totalPrecision = totalPrecision + precision;
                
                userTestItemCount = UIMatrixUtils.getNumberOfRatingsOfUser(obj.testSet, userIndex, obj.nilElement);
                recall = hit/userTestItemCount;
                totalRecall = totalRecall + recall;
                disp(totalHit/i);
                
                totalCount = totalCount + 1;
            end
            
            precision = totalPrecision/totalCount;
            recall = totalRecall/totalCount;
            obj.result.precision = precision;
            obj.result.recall = recall;
            obj.result.f1 = (2*recall*precision)/(recall+precision);

            disp(obj.result);
        end
        
        function time = timeOnePrediction(obj, userIndex, itemIndex)
            tic;
            obj.calculateFullPrediction(userIndex, itemIndex);
            time = toc;
        end

   end
   
end