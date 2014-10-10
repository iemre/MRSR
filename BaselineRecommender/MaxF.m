classdef MaxF < AbstractExperiment
    
    properties
    end
    
    methods (Access = private)
        function obj = MaxF(baseSet, testSet)
            obj = obj@AbstractExperiment(baseSet, testSet);
        end
    end
    
    
    methods (Static)
        function recom = createNew(baseSet, testSet)
            recom = MaxF(baseSet,testSet);
        end
    end
    
    
    methods
        function topNList = generateTopNListForUser(obj, n, ~)
            allData = UIMatrixUtils.mergeBaseAndTestSet(obj.baseSet, obj.testSet, obj.nilElement);
            [itemIndices, ~] = obj.getTopHitItems(allData);
            if length(itemIndices) < n
                topNList = itemIndices;
            else
                topNList = itemIndices(1:n);
            end
        end
        
        function topNList = generateTopNListForTestSetForUser(obj, n, userIndex)
            [itemIndices, ~] = obj.getTopHitItems(obj.baseSet);
            topNList = [];
            
            for k = 1:length(itemIndices)
                itemIndex = itemIndices(k);
                if UIMatrixUtils.userHasNotRatedItem(obj.baseSet, userIndex, itemIndex, obj.nilElement)
                    topNList = [topNList itemIndex];
                end
                if length(topNList) == n
                    break;
                end
            end
        end
        
        function prediction = calculateFullPrediction(obj, userIndex, itemIndex)
            % not implemented
        end
        
        function initialiseForCPP(obj)
            % not implemented
        end
       
        function [itemIndices, hits] = getTopHitItems(obj, data)
            % Returns the most hit (picked) item indices and the number of
            % hits (picks)
                                                    
            missingRatingsOfItems = sum(data(:,:) == obj.nilElement);
            [sortedMissingRatings, itemIndices] = sort(missingRatingsOfItems);
            hits = ones(1, obj.itemCount)*obj.userCount - sortedMissingRatings;
            
        end
    
        function cpp = calculateCPPByMaxF(obj)
            [topHitItemIndices, ~] = obj.getTopHitItems(obj.baseSet);
            allData = UIMatrixUtils.mergeBaseAndTestSet(obj.baseSet, obj.testSet, obj.nilElement);
            
            totalCpp = 0;
            countUser = 0;
            for userIndex = 1:obj.userCount
                correctlyPlacedCount = 0;
                fprintf('processing user %d\n', userIndex);
                itemsUserHasNotRated = find(allData(userIndex, :) == obj.nilElement);
                if isempty(itemsUserHasNotRated)
                    continue;
                end
                for i = 1:obj.itemCount-1
                    if UIMatrixUtils.userHasRatedItem(obj.testSet, userIndex, topHitItemIndices(i), obj.nilElement)
                        members = ismember((i+1):obj.itemCount, itemsUserHasNotRated);
                        correctlyPlacedCount = correctlyPlacedCount + sum(members);
                    end
                end      
                
                userTestRatingCount = UIMatrixUtils.getNumberOfRatingsOfUser(obj.testSet, userIndex, obj.nilElement);
                userAllRatingCount = UIMatrixUtils.getNumberOfRatingsOfUser(allData, userIndex, obj.nilElement);
                
                totalCpp = totalCpp + correctlyPlacedCount/(userTestRatingCount*(obj.itemCount-userAllRatingCount));
                countUser = countUser + 1;
            end
            
            cpp = totalCpp / countUser;
            disp(cpp);
        end
                
    end
    
end

