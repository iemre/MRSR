classdef ItemBasedKNNTest < matlab.unittest.TestCase
   
    properties
        originalPath
    end
    
    methods (TestMethodSetup)
        function addToPath(testCase)
           testCase.originalPath = path;
           addpath(fullfile(pwd, '../KNN/'));
           addpath(fullfile(pwd, '..'));
       end
    end
    
    methods (TestMethodTeardown)
        function restorePath(testCase)
           path(testCase.originalPath)
       end
    end
    
    methods (Test)
        
        function shouldCreateNewExperimentWithDatasets(testCase)
            baseSet = [1 2 0; 0 0 1];
            testSet = [0 0 5; 2 3 0];
            knnTest = ItemBasedKNN.createNewWithDatasets(baseSet, testSet);
            
            testCase.verifyEqual(knnTest.baseSet, baseSet);
            testCase.verifyEqual(knnTest.testSet, testSet);
        end
        
        function shouldSetDefaultParametersOfKNN(testCase)
            baseSet = [1 2 0; 0 0 1];
            testSet = [0 0 5; 2 3 0];
            
            knnTest = ItemBasedKNN.createNewWithDatasets(baseSet, testSet);

            testCase.verifyEqual(knnTest.k, 10);
            testCase.verifyEqual(knnTest.nilElement, 0);
            testCase.verifyEqual(length(knnTest.similarities), length(testSet(1, :)));
            testCase.verifyEqual(length(knnTest.similarItemIndexes), length(testSet(1, :)));
        end
        
        function shouldRunWithNoError(testCase)
            baseSet = [1 2 0; 0 0 1];
            testSet = [0 0 5; 2 3 0];
            
            knnTest = ItemBasedKNN.createNewWithDatasets(baseSet, testSet);
            
            knnTest.calculateErrorUsingMatlabKNN(1);
        end
        
    end
end