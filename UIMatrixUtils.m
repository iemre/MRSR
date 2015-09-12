% =====================================================================
% This class contains some useful static methods for User-Item matrix 
% operations.
% =====================================================================

classdef UIMatrixUtils
    methods(Static)
        
        function result = userHasRatedItem(uiMatrix, userIndex, itemIndex, nilElement)
            % returns true if rating at (userIndex, itemIndex) 
            % is not equal to nilElement
        
            if uiMatrix(userIndex, itemIndex) == nilElement
                result = 0;
                return;
            end
            
            result = 1;
        end
        
        function result = userHasNotRatedItem(uiMatrix, userIndex, itemIndex, nilElement)
            result = UIMatrixUtils.userHasRatedItem(uiMatrix, userIndex, itemIndex, nilElement) == 0;
        end
        
        function result = userHasNoRatings(uiMatrix, userIndex, nilElement)
            % returns true if the given user has no
            % ratings data in the given user-item matrix
            if any(uiMatrix(userIndex, :) ~= nilElement)
                result = 0;
                return;
            end
            
            result = 1;
        end
        
        function sparsityRate = sparsity(A, nilElement)
            % returns the sparsity level of matrix
            % formula: (#zero_elements) / (#all_elements)
        
            zeroElements = length(find(A == nilElement));
            [r, c] = size(A);
            total = r * c;
            sparsityRate = zeroElements/total;
        end
        
        function densityRate = density(A, nilElement)
            % returns the DensityRate of matrix A
            % DensityRate = 1 - sparsity (see the function sparsityRate)
        
            densityRate = 1 - UIMatrixUtils.sparsity(A, nilElement);
        end
        
        function result = isCellArrayEmpty(cellArray)
            if iscell(cellArray) == 0
                error('isCellArrayEmpty: Argument is not of type cell');
            end
            
            for i = 1:length(cellArray)
                if isempty(cellArray{i}) == 0
                    result = 0;
                    return;
                end
            end
            
            result = 1;
        end
        
        function result = hoyerSparseness(sparseMatrix)
            %   calculates the sparseness defined in 
            %   "Non-negative Matrix Factorization with 
            %   Sparseness Constraints" by Hoyer
            %   the input sparseMatrix is assumed to have the sparse
            %   representations of signals as columns
        
            colCount = length(sparseMatrix(1, :));
            rowCount = length(sparseMatrix(:, 1));
            
            totalCount = 0;
            totalSparsity = 0;
            for i = 1:colCount
                l1Norm = norm(sparseMatrix(:, i), 1);
                l2Norm = norm(sparseMatrix(:, i), 2);
                sh = sqrt(rowCount) - (l1Norm/l2Norm);
                if isnan(sh)
                    sh = 0;
                end
                sh = sh / (sqrt(rowCount) - 1);
                totalSparsity = totalSparsity + sh;
                totalCount = totalCount + 1;
            end
            
            result = totalSparsity / totalCount;
        end
        
        function result = getVectorDensity(vector, nilElement)
            result = length(vector(vector ~= nilElement)) / length(vector);
        end
        
        function result = normaliseVector(vector, nilElement)
        % maps vector elements to a scale of 0-1
        
            [rowCount, colCount] = size(vector);
            if rowCount ~= 1 && colCount ~= 1
                error('Cannot normalise a matrix that is not a vector');
            end
            elementCount = max(rowCount, colCount);
            
            maxVal = max(vector);
            minVal = min(vector);
            
            result = ones(1, elementCount) * nilElement;
            
            for i = 1:elementCount
                if isinf(vector(i))
                    result(i) = 1;
                end
                if vector(i) == nilElement
                    continue;
                end
                result(i) = (vector(i)-minVal) / (maxVal-minVal);
            end
        end
        
        function result = getNumberOfRatingsOfUser(matrix, userIndex, nilElement)
            result = length(find(matrix(userIndex, :) ~= nilElement));
        end
        
        function [predictions, topNIndexes] = getSortedTopNListOfPredictions(n, predictedUserRatings)
            [predictions, topNIndexes] = sort(predictedUserRatings, 'descend');
            if length(topNIndexes) > n
                topNIndexes = topNIndexes(1:n);
                predictions = predictions(1:n);
            end
        end
        
        function result = filterGivenRatingsOfUser(userIndex, userRatingList, baseSet, nilElement)
            [m, n] = size(userRatingList);
            if m ~= 1 && n ~= 1
                error('userRatingList must be a vector');
            end
            
            userRatingList(baseSet(userIndex, :) ~= nilElement) = nilElement;
            result = userRatingList;
        end
        
        function result = mergeBaseAndTestSet(baseSet, testSet, nilElement)
            result = baseSet;
            result(testSet ~= nilElement) = testSet(testSet ~= nilElement);
        end
        
        function result = removeRowsWithNilRatingsInColumn(matrix, columnIndex, nilElement)
            nilRows = matrix(:, columnIndex) == nilElement;
            matrix(nilRows, :) = [];
            result = matrix;
        end
        
        function [itemIndices, matrix] = getItemsRatedByAllUsers(data, nilElement)
            % returns a pair [itemIndices, matrix] 
            % matrix includes only the items rated by all users
            % itemIndices are indices of items in the original data
            % which are rated by all users
            
            [rows, cols] = size(data);
            itemIndices = [];
            matrix = [];
            counter = 1;
            for j = 1:cols
                ratedByAll = logical(1);
                for i = 1:rows
                    if data(i, j) == nilElement
                        ratedByAll = logical(0);
                        break;
                    end
                end
                
                if ratedByAll
                    itemIndices(counter) = j;
                    matrix(:, counter) = data(:, j);
                    counter = counter + 1;
                end
            end
        end
         
        function result = getNumberOfRatingsGivenToItem(data, itemIndex, nilElement)
            result = length(find(data(:, itemIndex) ~= nilElement));
        end
        
        function itemIndices = getItemsRatedByUser(matrix, userIndex, nilElement)
            itemIndices = find(matrix(userIndex, :) ~= nilElement);
        end
        
        function result = getAverageRatingOfUser(data, userIndex, nilElement)
            userRatings = data(userIndex, :);
            result = mean(userRatings(userRatings ~= nilElement));
        end
        
        function result = getAverageRating(data, nilElement)
            result = mean(data(data ~= nilElement));
        end
        
    end     
end