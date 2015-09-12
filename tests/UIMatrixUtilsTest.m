classdef UIMatrixUtilsTest < matlab.unittest.TestCase
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
       function shouldTrueWhenUserHasRatedItem(testCase)
           testData = [3 0 1; 2 3 0];
           result = UIMatrixUtils.userHasRatedItem(testData, 1, 1, 0);
           
           testCase.verifyEqual(result, 1);
       end
       
       function shouldReturnFalseWhenUserNotRatedItem(testCase)
           testData = [3 0 1; 2 3 0];
           result = UIMatrixUtils.userHasRatedItem(testData, 1, 2, 0);
           
           testCase.verifyEqual(result, 0);
       end
       
       function shouldReturnTrueWhenUserHasNoRatings(testCase)
           testData = [3 0 1; 0 0 0];
           userIndex = 2;
           nilElement = 0;
           result = UIMatrixUtils.userHasNoRatings(testData, userIndex, nilElement);
           
           testCase.verifyEqual(result, 1);
       end
       
       function shouldReturnFalseWhenUserHasAnyRatings(testCase)
           testData = [0 0 3; 0 0 0];
           userIndex = 1;
           nilElement = 0;
           result = UIMatrixUtils.userHasNoRatings(testData, userIndex, nilElement);
           
           testCase.verifyEqual(result, 0);
       end
       
       function shouldCalculateVectorDensityCorrectly(testCase)
           vector = [0 0 1 5 0 2];
           density = UIMatrixUtils.getVectorDensity(vector, 0);
           
           testCase.verifyEqual(density, 3/6);
       end
       
       function shouldReturnTrueWhenCellArrayIsEmpty(testCase)
           array = cell(5, 1);
           
           testCase.verifyEqual(UIMatrixUtils.isCellArrayEmpty(array), 1);
       end
       
       function shouldReturnFalseWhenCellArrayIsNotEmpty(testCase)
           array = cell(5, 1);
           array{1} = [4 3];
           
           testCase.verifyEqual(UIMatrixUtils.isCellArrayEmpty(array), 0);
       end
       
       function shouldNormaliseVectorCorrectly(testCase)
           vector = [1 5 0 3 0 4 2];
           normalised = UIMatrixUtils.normaliseVector(vector, 0);
           
           testCase.verifyEqual(normalised, [0.2 1 0 0.6 0 0.8 0.4]);
       end
       
       function shouldReturnNumberOfRatedItemsOfUser(testCase)
           matrix = [0 0 1; 5 0 1];
           result1 = UIMatrixUtils.getNumberOfRatingsOfUser(matrix, 1, 0);
           result2 = UIMatrixUtils.getNumberOfRatingsOfUser(matrix, 2, 0);
           
           testCase.verifyEqual(result1, 1);
           testCase.verifyEqual(result2, 2);
       end
       
       function shouldReturnTopNPredictionsAndIndexes(testCase)
           ratings = [1 0 5 3 9 5 2 6 3];
           [ratings, indexes] = UIMatrixUtils.getSortedTopNListOfPredictions(5, ratings);
           
           testCase.verifyEqual(indexes, [5 8 3 6 4]);
           testCase.verifyEqual(ratings, [9 6 5 5 3]);
       end
       
       function shouldFilterGivenUserRatings(testCase)
            userRatings = [1 0 2 4 5];
            baseSet = [0 0 2 0 5; 1 0 2 3 4; 34 3 4 1 0];
            result = UIMatrixUtils.filterGivenRatingsOfUser(1, ... 
                                userRatings, baseSet, 0);
                            
            testCase.verifyEqual(result, [1 0 0 4 0]);
       end
       
       function shouldMergeBaseAndTestSet(testCase)
            baseSet = [0 0 2 0 5; 1 0 2 3 4; 34 3 4 1 0];
            testSet = [1 0 0 0 0; 0 3 0 0 0; 0 0 0 0 7];
            result = UIMatrixUtils.mergeBaseAndTestSet(baseSet, testSet, 0);
            
            testCase.verifyEqual(result, [1 0 2 0 5; 1 3 2 3 4; 34 3 4 1 7]);
       end
       
       function shouldRemoveRowsWithNilRatingsInColumn(testCase)
           baseSet = [0 0 2 0 5; 1 0 2 3 4; 34 3 4 1 0]; 
           %{
                0  0 2 0 5
                1  0 2 3 4
                34 3 4 1 0
           %}
           
           result = UIMatrixUtils.removeRowsWithNilRatingsInColumn(baseSet, 2, 0);
           
           testCase.verifyEqual(result, [34 3 4 1 0]);
       end
       
       function shouldGetItemsRatedByAllUsers(testCase)
           baseSet = [0 0 2 0 5; 1 0 2 3 4; 34 3 4 1 1]; 
           nilElement = 0;
           [itemIndices, matrix] = UIMatrixUtils.getItemsRatedByAllUsers(baseSet, nilElement);
           
           testCase.verifyEqual(itemIndices, [3 5]);
       end
       
       function shouldGetNumberOfRatingsGivenToItem(testCase)
           baseSet = [0 0 2 0 5; 1 0 2 3 4; 34 3 4 1 0]; 
           %{
                0  0 2 0 5
                1  0 2 3 4
                34 3 4 1 0
           %}
           
           result = UIMatrixUtils.getNumberOfRatingsGivenToItem(baseSet, 4, 0);
           
           testCase.verifyEqual(result, 2);
       end
       
       function shouldGetItemsRatedByUser(testCase)
           baseSet = [0 0 2 0 5; 1 0 2 3 4; 34 3 4 1 0]; 
           
           items = UIMatrixUtils.getItemsRatedByUser(baseSet, 1, 0);
           
           testCase.verifyEqual(items, [3 5]);
       end
       
       function shouldGetAverageRatingOfUser(testCase)
           baseSet = [0 0 2 0 5; 1 0 2 3 4; 34 3 4 1 0]; 
           
           result = UIMatrixUtils.getAverageRatingOfUser(baseSet, 1, 0);
           
           testCase.verifyEqual(result, 3.5);
       end
       
       function shouldGetCustomerAverage(testCase)
           baseSet = [0 0 2 0 5; 1 0 2 3 4; 34 3 4 1 0]; 
           
           result = UIMatrixUtils.getAverageRating(baseSet, 0);
           
           testCase.verifyEqual(result, 5.9);
       end
       
   end
   
end