% ======================================================================
% This class provides various methods to calculate similarity 
% between two given vectors
% ======================================================================
classdef Similarity < handle
  
    properties
        nilElement
        similarityType
        userAverageRatings = [];
        sparseRepresentation = [];
        sparseDistance = [];
        similarityCache = [];
    end
    
    properties (Constant)
        ADJUSTED_COS = 1;
        PEARSON = 2;
        COSINE = 3;
        SPARSE = 4;
        RANDOM = 6;
        SPARSE_EUCLIDIAN = 7;
    end
    
    methods (Access = private)
 
        function obj = initialiseUserAverageRatings(obj, data)
            obj.userAverageRatings = zeros(length(data(:, 1)), 1);
            for i = 1:length(obj.userAverageRatings)
                fprintf('Calculating user average #%d\n', i);
                ratingIndexes = data(i,:) ~= obj.nilElement;
                userAverage = mean(data(i, ratingIndexes));
                obj.userAverageRatings(i) = userAverage;
            end
        end
        
    end
    
    methods (Static)
        
        function [obj] = newSimilarityCalculatorWithNilElementAndSimilarityType(nilElement, similarityType)
            if similarityType ~= Similarity.ADJUSTED_COS ...
            && similarityType ~= Similarity.PEARSON ...
            && similarityType ~= Similarity.COSINE ...
            && similarityType ~= Similarity.SPARSE ...
            && similarityType ~= Similarity.RANDOM ...
            && similarityType ~= Similarity.SPARSE_EUCLIDIAN
                error('Unknown similarity type given as argument');
            end
            
            obj = Similarity;
            obj.nilElement = nilElement;
            obj.similarityType = similarityType;
            obj.userAverageRatings = [];
        end
        
    end
    
    methods 
        
        function [result] = calculateItemSimilarity(obj, data, item1Index, item2Index)
            switch obj.similarityType
                case Similarity.PEARSON
                    result = obj.pearsonItemSimilarity(data, item1Index, item2Index);
                case Similarity.ADJUSTED_COS
                    result = obj.adjustedCosItemSimilarity(data, item1Index, item2Index);
                case Similarity.COSINE
                    result = obj.cosineItemSimilarity(data, item1Index, item2Index);
                case Similarity.SPARSE
                    result = obj.sparseItemSimilarity(data, item1Index, item2Index);
                case Similarity.RANDOM
                    result = obj.randomItemSimilarity();
                case Similarity.SPARSE_EUCLIDIAN
                    result = obj.sparseEuclidianSimilarity(data, item1Index, item2Index);                    
            end
            if isnan(result)
                    result = 0;
            end
        end
        
    end
    
    methods (Access = private)
        
        function result = adjustedCosItemSimilarity(obj, data, item1Index, item2Index)
            if isempty(obj.userAverageRatings)
                obj.initialiseUserAverageRatings(data);
            end
                
            item1 = data(:, item1Index);
            item2 = data(:, item2Index);

            nominator = 0;

            squareSum1 = 0;
            squareSum2 = 0;

            for i = 1:length(item1)
                if item1(i) == obj.nilElement || item2(i) == obj.nilElement
                    % only "corated pairs" are considered (Sarwar et al.)
                    continue;
                end
                
                userAverage = obj.userAverageRatings(i);
                
                diff1 = (item1(i) - userAverage);
                diff2 = (item2(i) - userAverage);
                nominator = nominator + diff1*diff2;
                squareSum1 = squareSum1 + diff1^2;
                squareSum2 = squareSum2 + diff2^2;
            end

            denominator = sqrt(squareSum1) * sqrt(squareSum2);

            result = nominator / denominator;
        end
        
        function result = pearsonItemSimilarity(obj, data, item1Index, item2Index)
            item1 = data(:, item1Index);
            item2 = data(:, item2Index);
            
            item1Average = mean(item1);
            item2Average = mean(item2);
            
            nominator = 0;

            squareSum1 = 0;
            squareSum2 = 0;

            for i = 1:length(item1)
                diff1 = (item1(i) - item1Average);
                diff2 = (item2(i) - item2Average);
                nominator = nominator + diff1*diff2;
                squareSum1 = squareSum1 + diff1^2;
                squareSum2 = squareSum2 + diff2^2;
            end

            denominator = sqrt(squareSum1 * squareSum2);

            result = nominator / denominator;
            if isnan(result)
                result = 0;
            end
        end        
        
        function result = cosineItemSimilarity(obj, data, item1Index, item2Index)
            item1 = data(:, item1Index);
            item2 = data(:, item2Index);
            
            nominator = dot(item1, item2);
            denominator = norm(item1) * norm(item2);            

            result = nominator/denominator;
        end        
        
        function result = sparseEuclidianSimilarity(obj, data, item1Index, item2Index)
            if isempty(obj.sparseRepresentation)
                sparse = SparseCoderExperiment.createItemBasedExperiment(data, data);
                sparse.solver = SparseCoder.PCBC;
                sparse.reconstructAll();
                obj.sparseRepresentation = sparse.normalisedSparseRepresentation;
                [~, columns] = size(data);
                obj.sparseDistance = zeros(columns, columns);
                
                for i = 1:columns
                    for j = 1:columns
                        rep1 = obj.sparseRepresentation(:, i);
                        rep2 = obj.sparseRepresentation(:, j);
                        obj.sparseDistance(i, j) = norm(rep1 - rep2);
                    end
                end
                
                for i = 1:columns
                    distances = obj.sparseDistance(i, :);
                    similarities = 1./distances;
                    similarities(similarities == Inf) = max(similarities(similarities < Inf)) + 1;
                    similarities = UIMatrixUtils.normaliseVector(similarities, obj.nilElement);
                    obj.similarityCache(i, :) = similarities;
                end
            end
            
            result = obj.similarityCache(item1Index, item2Index);
        end
        
        function result = sparseItemSimilarity(obj, data, item1Index, item2Index)
            if isempty(obj.sparseRepresentation)
                sparse = SparseCoderExperiment.createItemBasedExperiment(data, data);
                sparse.solver = SparseCoder.PCBC;
                sparse.reconstructAll();
                obj.sparseRepresentation = sparse.normalisedSparseRepresentation;
            end
               
            item1Similarities = obj.sparseRepresentation(:, item1Index);
            
            result = item1Similarities(item2Index);
        end        
        
        function result = randomItemSimilarity(obj)
            result = rand();
        end
        
    end
    
end
