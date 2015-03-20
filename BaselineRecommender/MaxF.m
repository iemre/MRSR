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
        
        function prediction = makePrediction(obj, userIndex, itemIndex)
            % not implemented
        end
        
        function initialize(obj)
            % not implemented
        end
       
        function [itemIndices, hits] = getTopHitItems(obj, data)
            % Returns the most hit (picked) item indices and the number of
            % hits (picks)
                                                    
            missingRatingsOfItems = sum(data(:,:) == obj.nilElement);
            [sortedMissingRatings, itemIndices] = sort(missingRatingsOfItems);
            hits = ones(1, obj.itemCount)*obj.userCount - sortedMissingRatings; 
        end
                
    end
    
end

