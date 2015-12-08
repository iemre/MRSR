%=====================================================================
% Sample Recommender 
% This class shows how you can implement your own algorithm
% within the MRSR framework.
% =====================================================================

classdef SampleRecommender < AbstractExperiment
    
    
    properties
    end
    
    methods (Access = private)
        
        function obj = SampleRecommender(baseSet, testSet)
            obj = obj@AbstractExperiment(baseSet, testSet);
        end
    end
    
    methods (Static)

        function recommender = createNewExperiment(baseSet, testSet)
            recommender = SampleRecommender(baseSet, testSet);
        end

    end

    methods

        function topNList = generateTopNListForUser(obj, n, userIndex)
         % your top-n recommendation logic (top-n may include ANY item)
        end

        function topNList = generateTopNListForTestSetForUser(obj, n, userIndex)
         % your top-n recommendation logic (top-n may only include items not in the training set)
        end
        function prediction = makePrediction(obj, userIndex, itemIndex)
	 % rating prediction
        end
        function initialize(obj)
	 % you may leeave this blank - in retrospect, this method may be unnecessary, although it must be implemented
        end
        
    end

end
