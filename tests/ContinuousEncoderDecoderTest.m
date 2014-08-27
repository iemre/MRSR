classdef ContinuousEncoderDecoderTest < matlab.unittest.TestCase
   properties
       originalPath
   end
   
   methods (TestMethodSetup)
       function addToPath(testCase)
           testCase.originalPath = path;
           addpath(fullfile(pwd, '..'));
           addpath(fullfile(pwd, '../RatingEncoders/'));
       end
   end
   
   methods (TestMethodTeardown)
       function restorePath(testCase)
           path(testCase.originalPath)
       end
   end
   
   methods (Test)
       
       function testEncoderEncodesIntegersCorrectly(testCase)
           encoder = ContinuousEncoderDecoder.createNewEncoderWithMinAndMaxRating(1, 5);
           [x1, x2] = encoder.encode(1);
           testCase.verifyEqual([x1, x2], [1 0]);
       end
       
       function testEncoderEncodesFloatingValuesCorrectly(testCase)
           encoder = ContinuousEncoderDecoder.createNewEncoderWithMinAndMaxRating(1, 5);
           [x1, x2] = encoder.encode(1.2);
           testCase.verifyEqual([x1, x2], [0.96 0.04], 'AbsTol', 0.0001);
       end
       
       function testEncoderDecodesIntegersCorrectly(testCase)
           decoder = ContinuousEncoderDecoder.createNewEncoderWithMinAndMaxRating(1, 5);
           r = decoder.decode([1 0]);
           testCase.verifyEqual(r, 1, 'AbsTol', 0.000001);
       end
       
       function testEncoderDecodesFloatingValuesCorrectly(testCase)
           decoder = ContinuousEncoderDecoder.createNewEncoderWithMinAndMaxRating(1, 5);
           r = decoder.decode([0.96 0.04]);
           testCase.verifyEqual(r, 1.2, 'AbsTol', 0.00001);
       end
       
       function testEncoderShouldEncodeZeroCorrectly(testCase)
           encoder = ContinuousEncoderDecoder.createNewEncoderWithMinAndMaxRating(1, 5);
           [x1, x2] = encoder.encode(0);
           testCase.verifyEqual([x1, x2], [0, 0], 'AbsTol', 0.00001);
       end
       
       function testEncoderShouldDecodeZeroCorrectly(testCase)
           decoder = ContinuousEncoderDecoder.createNewEncoderWithMinAndMaxRating(1, 5);
           r = decoder.decode([0 0]);
           testCase.verifyEqual(r, 0, 'AbsTol', 0.00001);
       end
       
       function testEncoderEncodesMatrixVertically(testCase)
           encoder = ContinuousEncoderDecoder.createNewEncoderWithMinAndMaxRating(1, 5);
           encodedMatrix = encoder.encodeMatrixVertical([4 5; 0 1]);
           testCase.verifyEqual(encodedMatrix, [0.4 0.2; 0.6 0.8; 0 1; 0 0], 'AbsTol', 0.0001);
       end
       
       function testEncoderDecodesMatrixVertically(testCase)
           decoder = ContinuousEncoderDecoder.createNewEncoderWithMinAndMaxRating(1, 5);
           decodedData = decoder.decodeMatrixVertical([0.4 0.2; 0.6 0.8; 0 1; 0 0]);
           testCase.verifyEqual(decodedData, [4 5; 0 1], 'AbsTol', 0.0001);
       end
       
       function testEncoderEncodesMatrixHorizontally(testCase)
           encoder = ContinuousEncoderDecoder.createNewEncoderWithMinAndMaxRating(1, 5);
           encodedMatrix = encoder.encodeMatrixHorizontal([4 5 0 2; 0 1 3 1]);
           testCase.verifyEqual(encodedMatrix, [0.4 0.6 0.2 0.8 0 0 0.8 0.2; 0 0 1 0 0.6 0.4 1 0], 'AbsTol', 0.0001);
       end
       
       function testEncoderDecodesMatrixHorizontally(testCase)
           encoder = ContinuousEncoderDecoder.createNewEncoderWithMinAndMaxRating(1, 5);
           decodedMatrix = encoder.decodeMatrixHorizontal([0.4 0.6 0.2 0.8 0 0 0.8 0.2; 0 0 1 0 0.6 0.4 1 0]);
           testCase.verifyEqual(decodedMatrix, [4 5 0 2; 0 1 3 1], 'AbsTol', 0.0001);
       end
       
   end
   
end