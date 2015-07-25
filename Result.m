% =====================================================================
% This class contains some properties to store experiment results, and some
% helper methods.
% =====================================================================

classdef Result < handle
    
    properties
        MAE
        NMAE
        RMSE
        hitRate
        nilElement
        hoyerSparsity
        cppRate
        itemHits = []
        coverageRate = 0;
        precision
        recall
        f1
    end
    
    methods
        function resetItemHits(obj, itemCount)
            obj.itemHits = zeros(itemCount, 1);
        end
        
        function increaseItemHitsInList(obj, topNList)
            for itemIndex = topNList
                obj.itemHits(itemIndex) = obj.itemHits(itemIndex) + 1;
            end
        end
        
        function obj = setErrorMetrics(obj, experiment, totalError, predictionCount)
            obj.MAE = totalError / predictionCount;
            range = (max(max(experiment.baseSet(:,:))) - min(min((experiment.baseSet(:, :)))));
            obj.NMAE = obj.MAE / range;
        end
        
        function obj = setRMSE(obj, totalSquaredError, predictionCount)
            obj.RMSE = sqrt(totalSquaredError/predictionCount);
        end
        
        function setCoverageRate(obj)
            indexes = find(obj.itemHits ~= 0);
            obj.coverageRate = length(indexes)/length(obj.itemHits);
        end
    end
end

