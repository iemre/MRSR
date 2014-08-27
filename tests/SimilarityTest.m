classdef SimilarityTest < matlab.unittest.TestCase
   
    properties
        originalPath
    end
    
    methods (TestMethodSetup)
        function addToPath(testCase)
           testCase.originalPath = path;
           addpath(fullfile(pwd, '../KNN/'));
       end
    end
    
    methods (TestMethodTeardown)
        function restorePath(testCase)
           path(testCase.originalPath)
       end
    end
    
    methods (Test)
        
        function testCreateNewCalculatorWithNilElement(testCase)
            similarityCalculator = Similarity.newSimilarityCalculatorWithNilElementAndSimilarityType(5, Similarity.ADJUSTED_COS);
            
            testCase.verifyEqual(similarityCalculator.nilElement, 5);
        end
        
        function testAdjustedCosSimilarityReturnsOneWhenColumnsExactlySame(testCase)
            similarityCalculator = Similarity.newSimilarityCalculatorWithNilElementAndSimilarityType(0, Similarity.ADJUSTED_COS);
            data = [0 5 3; 0 5 3; 2 2 2]';
            similarity = similarityCalculator.calculateItemSimilarity(data, 1, 2);
            
            testCase.verifyEqual(similarity, 1, 'AbsTol', 0.0001);
        end
        
        function testCorrelationSimilarityReturnsOneWhenColumnsExactlySame(testCase)
            similarityCalculator = Similarity.newSimilarityCalculatorWithNilElementAndSimilarityType(0, Similarity.PEARSON);
            data = [0 5 3; 0 5 3]';
            similarity = similarityCalculator.calculateItemSimilarity(data, 1, 2);
            
            testCase.verifyEqual(similarity, 1);
        end
        
        function testCosineSimilarity(testCase)
            similarityCalculator = Similarity.newSimilarityCalculatorWithNilElementAndSimilarityType(0, Similarity.COSINE);
            data = [0 5 3; 0 1 3]';
            similarity = similarityCalculator.calculateItemSimilarity(data, 1, 2);
            
            testCase.verifyEqual(similarity, 0.75925, 'AbsTol', 0.0001);
        end
        
    end
end