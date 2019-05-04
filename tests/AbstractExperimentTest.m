classdef AbstractExperimentTest < matlab.unittest.TestCase
    properties
        originalPath
    end
    
    methods (TestMethodSetup)
        function addToPath(testCase)
           testCase.originalPath = path;
           addpath(fullfile(pwd, '..'));
       end
    end
    
    methods (TestMethodTeardown)
        function restorePath(testCase)
           path(testCase.originalPath)
       end
    end
    
    methods (Test)    
        
        function shouldSetDefaultMissingValueAsZero(testCase)
            exp = ItemBasedSparseCoderExperiment.createItemBasedExperiment(NaN, NaN);

            testCase.verifyEqual(exp.nilElement, 0);
        end
        
        function shouldSetDefaultMinAndMaxRatingsCorrectly(testCase)
            baseSet = [1 2 0; 0 0 1];
            testSet = [0 0 5; 2 3 0];
            
            exp = ItemBasedSparseCoderExperiment.createItemBasedExperiment(baseSet, testSet);

            testCase.verifyEqual(exp.maxRating, 5);
            testCase.verifyEqual(exp.minRating, 1);
        end
        
        function shouldCalculateRmseAndMaeCorrectly(testCase)
            baseSet = [4 0 3 5; 0 5 4 0; 5 4 2 0; 2 4 0 3; 3 4 5 0]; 
            testSet = [0 2 0 0; 1 0 0 0; 0 0 0 3; 0 0 1 0; 0 0 0 2];
            knnTest = ItemBasedKNN.createNewWithDatasets(baseSet, testSet); 
            knnTest.setSimilarityCalculatorTo(Similarity.COSINE);
            knnTest.k = 2;
            knnTest.calculatePredictiveAccuracy;
            
            testCase.verifyEqual(knnTest.result.MAE, 1.9250, 'AbsTol', 0.001);
            testCase.verifyEqual(knnTest.result.RMSE, 2.1106, 'AbsTol', 0.001);
        end
        
    end
    
end

