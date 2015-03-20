% =====================================================================
% This class is an attempt for an implementation of the Eigentaste
% algorithm proposed by Goldberg et al. 
% =====================================================================

classdef PCARecommender < AbstractExperiment
    
    properties
    end
    
    methods (Access = private)
        function obj = PCARecommender(baseSet, testSet)
            obj = obj@AbstractExperiment(baseSet, testSet);
        end
    end
    
    
    methods (Static)
        function recom = createNew(baseSet, testSet)
            recom = PCARecommender(baseSet,testSet);
        end
    end
    
    
    methods
        function topNList = generateTopNListForUser(obj, n, userIndex)
            % not implemented
        end
        function topNList = generateTopNListForTestSetForUser(obj, n, userIndex)
            % not implemented
        end
        function prediction = makePrediction(obj, userIndex, itemIndex);
            % not implemented
        end
        function initialize(obj)
            % not implemented
        end
       
        
        function showProjectionToPrincipleComponentPlane(obj)
            % This method projects users to Principle Component Plane
            % and plots the 2-D graph of projected users
            
            [selectedItemIndices, gaugeSet] = UIMatrixUtils.getItemsRatedByAllUsers(obj.baseSet, obj.nilElement);
            for j = 1:length(selectedItemIndices)
                avg = mean(gaugeSet(:, j));
                variance = var(gaugeSet(:, j));
                gaugeSet(:, j) = (gaugeSet(:, j) - avg) ./ variance;
            end
            
            c = (gaugeSet'*gaugeSet) .* 1/(obj.userCount-1);
            
            [eigenVectors] = pca(c);
            eigenPlaneVectors = eigenVectors(:, [1,2]);
            
            projection = gaugeSet * eigenPlaneVectors;
            projection = projection';
            plot(projection(1,:), projection(2,:), '.', 'markersize', 1);
            title('Projection of Users Onto the Principle Component Plane');
        end
        
    end
    
end

