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
        
    end
    
end

