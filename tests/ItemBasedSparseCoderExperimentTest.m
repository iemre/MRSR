classdef ItemBasedSparseCoderExperimentTest < matlab.unittest.TestCase
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
        
        function shouldCreateCreateWithDatasets(testCase)
            baseSet = [1 2 0; 0 0 1];
            testSet = [0 0 5; 2 3 0];
            sparseTest = ItemBasedSparseCoderExperiment.createItemBasedExperiment(baseSet, testSet);
            
            testCase.verifyEqual(sparseTest.baseSet, baseSet);
            testCase.verifyEqual(sparseTest.testSet, testSet);
        end
        
        function shouldSetDefaultParameters(testCase)
            baseSet = [1 2 0; 0 0 1];
            testSet = [0 0 5; 2 3 0];
            
            sparseTest = ItemBasedSparseCoderExperiment.createItemBasedExperiment(baseSet, testSet);

            testCase.verifyEqual(sparseTest.nilElement, 0);
            testCase.verifyEqual(sparseTest.result.nilElement, 0);
        end
        
        function shouldRemoveColumnsNotHavingRatingForUser(testCase)
            baseSet = [0 2 0; 0 5 4; 2 0 3];
            
            sparseTest = ItemBasedSparseCoderExperiment.createItemBasedExperiment(baseSet, NaN);
            userIndex = 1; activeItemIndex = 3; 
            [dictionary, remainingColumns] = sparseTest.removeColumnsNotHavingRatingForUser(baseSet, userIndex, activeItemIndex);
            
            testCase.verifyEqual(dictionary, [2 0; 5 4; 0 3]);
            testCase.verifyEqual(remainingColumns, [2, 3]);
        end
        
        function shouldRemoveUsersNotHavingRatingForItem(testCase)
            baseSet = [0 2 0; 0 5 0; 2 0 3];
            
            sparseTest = ItemBasedSparseCoderExperiment.createItemBasedExperiment(baseSet, NaN);
            activeItemIndex = 3; 
            dictionary = sparseTest.removeUsersNotHavingRatingForItem(baseSet, activeItemIndex);
            
            testCase.verifyEqual(dictionary, [2 0 3]);
        end
        
        function shouldNormaliseDictionaryCorrectly(testCase)
            baseSet = [0 2 4; 0 5 1; 2 0 3];
            
            sparseTest = ItemBasedSparseCoderExperiment.createItemBasedExperiment(baseSet, NaN);
            dictionary = sparseTest.normaliseDictionary(baseSet);
            
            testCase.verifyEqual(sum(dictionary(:,1)), 1);
            testCase.verifyEqual(sum(dictionary(:,2)), 1);
            testCase.verifyEqual(sum(dictionary(:,3)), 1);
        end
        
        function shouldRunWithoutColumnRemoval(testCase)
            baseSet = [0 2 4; 0 5 1; 2 0 3];
            
            sparseTest = ItemBasedSparseCoderExperiment.createItemBasedExperiment(baseSet, baseSet);
            sparseTest.calculateSimpleSparseItemReconstructionError
        end
        
        function shouldRunWithColumnRemoval(testCase)
            baseSet = [0 2 4; 0 5 1; 2 0 3];
            
            sparseTest = ItemBasedSparseCoderExperiment.createItemBasedExperiment(baseSet, baseSet);
            sparseTest.calculateErrorByColumnRemoval
        end
        
        function shouldRunNormalisedColumnRemoval(testCase)
            baseSet = [0 2 4; 0 5 1; 2 0 3];
            
            sparseTest = ItemBasedSparseCoderExperiment.createItemBasedExperiment(baseSet, baseSet);
            sparseTest.calculateErrorByNormalisedColumnRemoval
        end
        
    end
    
end

