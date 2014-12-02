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
       initialiseForCPP(obj)
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
            % generates top-n list of recommended items for each user in the range userIndices
            % and shows the coverage of recommended items
            
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
            % generates top-n list of recommended items for each user in the range userIndices
            % and shows the average recall, precision and F1
            
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

        function cpp = calculateCPP(obj, reconstruct)
            % This method calculates the CPP (Correctly Placed Pairs)
            % measure defined in "Random Walks in Recommender Systems: Exact Computation and Simulations" Cooper et al.
            % and in "Random-Walk Computation of Similarities between Nodes of a Graph with Application
            % to Collaborative Recommendation" as degree of agreement
            
            allData = UIMatrixUtils.mergeBaseAndTestSet(obj.baseSet, obj.testSet, obj.nilElement);
            
            if reconstruct
                obj.initialiseForCPP;
            end
            
            totalCpp = 0;
            countUser = 0;
            for userIndex = 1:obj.userCount
                userTestRatingCount = UIMatrixUtils.getNumberOfRatingsOfUser(obj.testSet, userIndex, obj.nilElement);
                if userTestRatingCount == 0
                    continue;
                end
                correctlyPlacedCount = 0;
                fprintf('processing user %d\n', userIndex);
                itemsUserHasNotRated = find(allData(userIndex, :) == obj.nilElement);
                
                if isempty(itemsUserHasNotRated)
                    % If user has rated all items then, by definition,
                    % CPP cannot be calculated for that user
                    continue;
                end
                
                topItemIndices = obj.generateTopNListForUser(obj.itemCount, userIndex);
                
                if isempty(topItemIndices)
                    % User 5159 in ML1M has no ratings to make
                    % recommendations. Ignore it.
                    continue;
                end
                
                for i = 1:obj.itemCount-1
                    if UIMatrixUtils.userHasRatedItem(obj.testSet, userIndex, topItemIndices(i), obj.nilElement)
                        members = ismember((i+1):obj.itemCount, itemsUserHasNotRated);
                        correctlyPlacedCount = correctlyPlacedCount + sum(members);
                    end
                end      
                
                userAllRatingCount = UIMatrixUtils.getNumberOfRatingsOfUser(allData, userIndex, obj.nilElement);
                totalCpp = totalCpp + correctlyPlacedCount/(userTestRatingCount*(obj.itemCount-userAllRatingCount));
                countUser = countUser + 1;
                cpp = totalCpp / countUser;
                disp(cpp);
            end
            
            cpp = totalCpp / countUser;
            obj.result.CPP = cpp;
            disp(obj.result);
        end
        
   end
   
end
