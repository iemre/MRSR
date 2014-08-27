% =====================================================================
% This class hosts properties and methods that are common to all sparse
% coding based recommender experiments. All sparse coding based 
% recommender experiments inherit this abstract class.
% =====================================================================
classdef (Abstract) AbstractSparseCoderExperiment < AbstractExperiment

    properties
        reconstruction
        solver
        sparseRepresentation
        normalisedSparseRepresentation
        similarities
        similarItemIndexes
    end
    
    methods (Abstract)
        result = userHasNotRatedItemInTestingSet(userIndex, itemIndex)
    end
    
    methods
    
        function obj = AbstractSparseCoderExperiment(baseSet, testSet)
            warning off MATLAB:rankDeficientMatrix;
            obj = obj@AbstractExperiment(baseSet, testSet);
        end
        
        function dictionary = getDictionaryForColumn(obj, columnIndex)
            dictionary = obj.baseSet; 
            item = dictionary(:, columnIndex);
            dictionary(:, columnIndex) = zeros(length(item), 1);
        end
        
        function [dictionary, column] = getDictionaryByRemovingNilRows(obj, columnIndex)
            dictionary = obj.baseSet; 
            dictionary = UIMatrixUtils.removeRowsWithNilRatingsInColumn(dictionary, columnIndex, obj.nilElement);
            column = dictionary(:, columnIndex);
            dictionary(:, columnIndex) = zeros(length(column), 1);
        end

        function calculateColumnSimilarities(obj, dataSet, simCalculator) 
            obj.similarities = cell(1, obj.itemCount);
            for i = 1:obj.itemCount
                fprintf('calculating similarities for item %d\n', i);
                for j = 1:obj.itemCount
                    if i == j
                        obj.similarities{i}(j) = 0;
                        continue;
                    end

                    obj.similarities{i}(j) = simCalculator.calculateItemSimilarity(dataSet, i, j);
                end
                [obj.similarities{i}, obj.similarItemIndexes{i}] = sort(obj.similarities{i}, 'descend');
            end
        end
        
    end
    
end
