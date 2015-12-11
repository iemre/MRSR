% This class is an attempt to implement a matrix factorisation based
% recommender system suggested by Koren et al. 
% in "MATRIX FACTORIZATION TECHNIQUES FOR RECOMMENDER SYSTEMS".
% This class uses the code from https://github.com/huajh/mf_re_sys

classdef MatrixFactorizationRecommender < AbstractExperiment
   
    properties
        predictionMatrix = [];
        
        % tune this during the training phase
        lambda = 4;
        
        % tune this during the training phase
        featureCount = 10;
        
        % set to 1 if you want the prediction matrix to be rounded
        roundPredictions = 0 
    end
    
    methods (Access = private)
        function obj = MatrixFactorizationRecommender(baseSet, testSet)
            obj = obj@AbstractExperiment(baseSet, testSet);
        end
    end
    
    
    methods (Static)
        function recom = createNew(baseSet, testSet)
            recom = MatrixFactorizationRecommender(baseSet,testSet);
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
            if isempty(obj.predictionMatrix)
                obj.initialize;
            end
            prediction = obj.predictionMatrix(userIndex, itemIndex);
        end
        
        function initialize(obj)
            L_train = obj.baseSet ~= obj.nilElement;
            Rating_train = obj.baseSet;
            P = mf_main(obj.lambda, obj.featureCount, L_train, Rating_train);
            if (obj.roundPredictions > 0 )
                obj.predictionMatrix = round(P);
            end
            obj.predictionMatrix = P;
            obj.predictionMatrix(obj.predictionMatrix > obj.maxRating) = obj.maxRating;
        end
        
    end
    
end

