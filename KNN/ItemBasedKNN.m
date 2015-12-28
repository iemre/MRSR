% ===============================================================================
% ItemBasedKNN contains some methods for the implementation of an item-based 
% K-Nearest-Neighbours recommender.
%
% Default similarity measure is PEARSON CORRELATION.
%
% Example:
% To run accuracy experiments, the user can simply do the following:
% exp = ItemBasedKNN.createNewWithDatasets(baseSet, testSet)
% exp.calculateErrorMetrics(Similarity.COSINE)
% ===============================================================================

classdef ItemBasedKNN < AbstractExperiment
    properties
        similarItemIndexes
        similarities
        k
        similarityCalculator
    end
    

    methods (Access = private)
        
        function items = getMostSimilarUnratedItems(obj, userIndex, ratedItemIndices, n)
            allSimItemIndices = [];
            for i = ratedItemIndices
                allSimItemIndices = [allSimItemIndices obj.similarItemIndexes{i}];
            end
            
            allSimilarities = [];
            for i = ratedItemIndices
                allSimilarities = [allSimilarities obj.similarities{i}];
            end
            
            [~, indices] = sort(allSimilarities, 'descend');
            items = [];
            
            for i = indices
                itemIndex = allSimItemIndices(i);
                if UIMatrixUtils.userHasRatedItem(obj.baseSet, userIndex, itemIndex, obj.nilElement)
                    continue;
                end
                if ismember(itemIndex, items) == 0
                    items = [items itemIndex];
                end
                if length(items) > n
                    break;
                end
            end
        end

        function items = getMostSimilarAllItems(obj, ratedItemIndices, n)
            allSimItemIndices = [];
            for i = ratedItemIndices
                allSimItemIndices = [allSimItemIndices obj.similarItemIndexes{i}];
            end
            
            allSimilarities = [];
            for i = ratedItemIndices
                allSimilarities = [allSimilarities obj.similarities{i}];
            end
            
            [~, indices] = sort(allSimilarities, 'descend');
            items = [];
            
            for i = indices
                itemIndex = allSimItemIndices(i);
                if ismember(itemIndex, items) == 0
                    items = [items itemIndex];
                end
                if length(items) > n
                    break;
                end
            end
        end
        
        function obj = ItemBasedKNN(baseSet, testSet)
            obj = obj@AbstractExperiment(baseSet, testSet);
        end
        
    end
    
    
    methods (Static)
        
        function KNN = createNewWithDatasets(baseSet, testSet)
            %  This method creates a new ItemBasedKNN experiment
            %  with given training dataset and testing dataset.
            %  Default k=10, and nilElement=0            
            
            KNN = ItemBasedKNN(baseSet, testSet);
            KNN.k = 10;
            KNN.similarities = cell(1, KNN.itemCount);
            KNN.similarItemIndexes = cell(1, KNN.itemCount);
            KNN.setSimilarityCalculatorTo(Similarity.PEARSON);
        end    
        
    end
    
    
    methods
        
        function [prediction] = predict(obj, userIndex, itemIndex)
            % This method calculates the prediction of the given user's rating
            % on the given item at itemIndex.
            % This function assumes similarities across 
            % all items are already calculated.
            
            neighbourhood = obj.similarItemIndexes{itemIndex};
            kNearestNeighbours = zeros(1, obj.k);
            ratedItemCount = 1;

            for j = 1:length(neighbourhood)
                if UIMatrixUtils.userHasRatedItem(obj.baseSet, userIndex, neighbourhood(j), obj.nilElement)
                    kNearestNeighbours(ratedItemCount) = neighbourhood(j);
                    ratedItemCount = ratedItemCount + 1;
                    if ratedItemCount > obj.k
                        break;
                    end
                end
            end

            nominator = 0;
            denominator = 0;

            for j = 1:length(kNearestNeighbours)
                if kNearestNeighbours(j) == 0
                    continue;
                end
                similarItemIndex = obj.similarItemIndexes{itemIndex} == kNearestNeighbours(j);
                similarity = obj.similarities{itemIndex}(similarItemIndex);
                nominator = nominator + similarity * obj.baseSet(userIndex, kNearestNeighbours(j));
                denominator = denominator + abs(similarity);
            end

            prediction = nominator/denominator;
            if isnan(prediction) 
                prediction = nan;
            end
        end
        
        function topNList = generateTopNListForUser(obj, n, userIndex)
            ratedItemIndices = UIMatrixUtils.getItemsRatedByUser(obj.baseSet, userIndex, obj.nilElement);
            
            items = obj.getMostSimilarAllItems(ratedItemIndices, n);
            
            if length(items) < n
                topNList = items;
            else
                topNList = items(1:n);
            end
        end
        
        function topNList = generateTopNListForTestSetForUser(obj, n, userIndex)
            ratedItemIndices = UIMatrixUtils.getItemsRatedByUser(obj.baseSet, userIndex, obj.nilElement);
            
            items = obj.getMostSimilarUnratedItems(userIndex, ratedItemIndices, n);
            if n > length(items)
                topNList = items;
                return;
            end
            
            topNList = items(1:n);
        end
        
        function obj = setSimilarityCalculatorTo(obj, similarityType)
            obj.similarityCalculator = Similarity.newSimilarityCalculatorWithNilElementAndSimilarityType(obj.nilElement, similarityType);
        end
        
        function obj = calculateItem2ItemSimilarities(obj)
            % This function calculates similarities between items.
            % Similarity values are sorted in descending order and
            % are kept in the object properties "similarities"
            % and "similarityItemIndexes".
                        
            obj.similarities = cell(1, obj.itemCount);
            obj.similarItemIndexes = cell(1, obj.itemCount);

            for i = 1:obj.itemCount
                obj.similarities{i} = zeros(1, obj.itemCount);
            end

            for i = 1:obj.itemCount
                fprintf('Calculating similar items to item #%d\n', i);
                for j = 1:obj.itemCount
                    if i == j
                        % Ekstrand - page 101 (The same item is not considered)
                        obj.similarities{i}(j) = 0;
                        continue;
                    end

                    sim = obj.similarityCalculator.calculateItemSimilarity(obj.baseSet, i, j);

                    obj.similarities{i}(j) = sim;
                end
            end

            for i = 1:obj.itemCount
                fprintf('Sorting item similarity values of item #%d...\n', i);
                [obj.similarities{i}, obj.similarItemIndexes{i}] = sort(obj.similarities{i}, 'descend');
            end
            
        end
        
        function obj = calculateSimilaritiesUsingMatlabKNN(obj)
            for itemIndex = 1:obj.itemCount
                fprintf('Calculating similar items to item %d\n', itemIndex);
                [neighbourIndexes, distances] = knnsearch(obj.baseSet', obj.baseSet(:, itemIndex)', 'distance', 'correlation', 'k', obj.itemCount);
                neighbourIndexes = [neighbourIndexes(2:end), itemIndex];
                distances = distances(2:end);
                similarityRates = [1 - distances, 0];
                similarityRates(isnan(similarityRates)) = 0;
                obj.similarItemIndexes{itemIndex} = neighbourIndexes;
                obj.similarities{itemIndex} = similarityRates;
            end 
        end
        
        function prediction = makePrediction(obj, userIndex, itemIndex)
            obj.initialize;
            prediction = obj.predict(userIndex, itemIndex);
        end
         
        function initialize(obj)
            % Important: For performance, if similarities are calculated once,
            % they are not calculated again. To calculate them again,
            % the user should assign the "similarities" property to an
            % empty array.
            
            if isempty(obj.similarities{1}) == 0
                return;
            end
            % obj.calculateSimilaritiesUsingMatlabKNN;
            obj.calculateItem2ItemSimilarities;
        end
    end

end