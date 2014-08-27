classdef ResultTest < matlab.unittest.TestCase
    
    properties
        originalPath
    end
    
    methods (TestMethodSetup)
        function addToPath(testCase)
           testCase.originalPath = path;
           addpath(fullfile(pwd, '../'));
       end
    end
    
    methods (TestMethodTeardown)
        function restorePath(testCase)
           path(testCase.originalPath)
       end
    end
    
    methods (Test)
        
        function shouldSetMAEandNMAECorrectly(testCase)
            baseSet = [2 0 4; 0 3 0];
            testSet = [0 1 0; 5 0 4];
            
            result = Result;
            experiment = ItemBasedKNN.createNewWithDatasets(baseSet, testSet);
            totalError = 5; totalPredictionCount = 6;
            result.setErrorMetrics(experiment, totalError, totalPredictionCount);
            
            testCase.verifyEqual(result.MAE, 0.833, 'AbsTol', 0.001);
            testCase.verifyEqual(result.NMAE, 0.833/4, 'AbsTol', 0.001);
        end
        
        function shouldIncreaseItemHitsFromList(testCase)
            result = Result;
            result.resetItemHits(5);
            topNList1 = [1 5 3];
            topNList2 = [1 3];
            
            result.increaseItemHitsInList(topNList1);
            result.increaseItemHitsInList(topNList2);
            result.increaseItemHitsInList(3);
            
            testCase.verifyEqual(result.itemHits, [2 0 3 0 1]');
        end
        
    end
    
    
end

