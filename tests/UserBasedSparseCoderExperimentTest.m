classdef UserBasedSparseCoderExperimentTest < matlab.unittest.TestCase
    properties
        originalPath
    end
    
    methods (TestMethodSetup)
        function addToPath(testCase)
           testCase.originalPath = path;
           addpath(fullfile(pwd, '../SparseCoding/'));
           addpath(fullfile(pwd, '..'));
       end
    end
    
    methods (TestMethodTeardown)
        function restorePath(testCase)
           path(testCase.originalPath)
       end
    end
    
    methods (Test)
        
        function shouldRemoveFromDictionaryItemsNotRatedByUser(testCase)
            baseSet = [1 2 0; 0 0 1; 0 1 0; 0 1 5]';
            
            sparseTest = UserBasedSparseCoderExperiment.createUserBasedExperiment(baseSet, NaN);
            baseSet = sparseTest.removeItemsNotRatedByUser(baseSet', 3);
            
            testCase.verifyEqual(baseSet, [0 0 1; 0 1 5]);
        end
        
        function shouldReturnTrueIfUserHasNotRatedItemInTestingSet(testCase)
            baseSet = [1 2 0; 0 0 1; 0 1 0; 0 1 5];
            testSet = [0 0 1; 0 2 0; 0 0 0; 2 0 0];
            sparseTest = UserBasedSparseCoderExperiment.createUserBasedExperiment(baseSet, testSet);
            result = sparseTest.userHasNotRatedItemInTestingSet(1, 2);
            
            testCase.verifyTrue(result);
        end
        
        
        function shouldReturnFalseIfUserHasRatedItemInTestingSet(testCase)
            baseSet = [1 2 0; 0 0 1; 0 1 0; 0 1 5];
            testSet = [0 0 1; 0 2 0; 0 0 0; 2 0 0];
            sparseTest = UserBasedSparseCoderExperiment.createUserBasedExperiment(baseSet, testSet);
            result = sparseTest.userHasNotRatedItemInTestingSet(4, 1);
            
            testCase.verifyFalse(result);
        end
        
        function shouldRemoveFromDictionaryUsersNotRatedItemExceptTheCurrentUser(testCase)
            baseSet = [1 2 0; 0 0 1; 0 1 0; 0 1 5];
            itemIndex = 3;
            currentUserIndex = 3;
            sparseTest = UserBasedSparseCoderExperiment.createUserBasedExperiment(baseSet, NaN);
            [dictionary, selectedColumns] = sparseTest.removeColumnsNotHavingItemRating(baseSet', itemIndex, currentUserIndex);
            
            testCase.verifyEqual(dictionary, [0 0 1; 0 1 0; 0 1 5]');            
            testCase.verifyEqual(selectedColumns, [2,3,4]);
        end
        
    end
    
end

