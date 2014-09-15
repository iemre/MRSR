classdef MaxFTest < matlab.unittest.TestCase
   
    properties
        originalPath
    end
    
    methods (TestMethodSetup)
        function addToPath(testCase)
           testCase.originalPath = path;
           addpath(fullfile(pwd, '../BaselineRecommender/'));
           addpath(fullfile(pwd, '..'));
       end
    end
    
    methods (TestMethodTeardown)
        function restorePath(testCase)
           path(testCase.originalPath)
       end
    end
    
    methods (Test)
        
        function shouldGetTopHitItems(testCase)
            baseSet = [1 2 1; 0 0 1; 0 5 4];
            testSet = [0 0 5; 2 3 0; 0 0 0];
            test = MaxF.createNew(baseSet,testSet);
            
            [topHitItems, hits] = test.getTopHitItems(baseSet);
            
            testCase.verifyEqual(topHitItems, [3 2 1]);
            testCase.verifyEqual(hits, [3 2 1]);
        end
        
        function shouldGetTopHitItems2(testCase)
            baseSet = [1 2 1; 0 0 1; 0 5 4; 0 0 5];
            testSet = [0 0 5; 2 3 0; 0 0 0; 0 0 0];
            test = MaxF.createNew(baseSet,testSet);
            
            [topHitItems, hits] = test.getTopHitItems(baseSet);
            
            testCase.verifyEqual(topHitItems, [3 2 1]);
            testCase.verifyEqual(hits, [4 2 1]);
        end
        
    end
end