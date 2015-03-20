==============================LICENSE====================================
MATLAB Recommender System Research Software
Copyright (C) 2014  Ismail Emre Kartoglu

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

=========================================================================
This folder contains some files of MATLAB code used for the experiments in the M.Sc. thesis titled "A Recommender System Based on Sparse Dictionary Coding" by Ismail Emre Kartoglu (King's College London, 2014)

MRSR is a set of MATLAB classes for recommender systems research.
The idea is to gather all the recommender system algorithms and make reliable comparisons.
The user can test their own algorithm by inheriting the AbstractExperiment class and implementing the abstract methods.
Example use cases are described in what follows.

Important note: 
=======================
To be able to run a sparse coder experiment, the user must download the sparse coders encapsulated by the SparseCoder.m file.

The user can download the PC/BC-DIM algorithm using this link: http://www.inf.kcl.ac.uk/staff/mike/Code/sparse_classification.zip 

SolveDALM.m, SolveFISTA.m, SolveOMP.m, SolvePFP.m, and SolveSpaRSA.m algorithms/files can be downloaded using the following web pages (24/08/2014):

http://www.eecs.berkeley.edu/~yang/software/l1benchmark/
http://sparselab.stanford.edu/


Example 1 - Using the item-based KNN recommender:
==========================================================
test = ItemBasedKNN.createNewWithDatasets(baseSet, testSet)
test.k = 10
test.calculatePredictiveAccuracy; % calculate MAE and RMSE
test.setSimilarityCalculatorTo(Similarity.COSINE);
numberOfUsers = 943;
test.showPrecisionAndRecall(10, [1:numberOfUsers)]


Example 2 - Using the item-based sparse coding recommender:
==========================================================
test = ItemBasedSparseCoderExperiment.createItemBasedExperiment(baseSet, testSet)
test.calculatePredictiveAccuracy; % calculate MAE and RMSE
numberOfUsers = 943;
test.showPrecisionAndRecall(10, [1:numberOfUsers]) 

% The above code will print the results.
% However, the user might want to access the results as follows:

mae = test.result.MAE
rmse = test.result.RMSE
cpp = test.result.cppRate
recall = test.result.recall
precision = test.result.precision
f1 = test.result.f1


To measure the performance of the user's own algorithm:
==========================================================

Create a class, make it inherit the AbstractExperiment class, and implement the following abstract methods in AbstractExperiment class:

       % Generate a top-n list for the given user. The list may contain
       % an item that is already rated.
       topNList = generateTopNListForUser(obj, n, userIndex); 
       
       % Geneate a top-n list for the given user. The list may contain
       % only the unrated items.
       topNList = generateTopNListForTestSetForUser(obj, n, userIndex);
       
       % Predict the rating of the given user userIndex for the item with itemIndex.
       prediction = makePrediction(obj, userIndex, itemIndex);
       
       % Make initial calculations. This may be similarity matrix
       % calculation for k-NN algorithm, or sparse reconstruction for
       % sparse coding. Some of the evaluation methods below call this
       % function before they start their job.
       initialize(obj);       
       
After implementing these methods, the user can measure the CPP, recall, precision, MAE and RMSE of their own algorithm and safely compare 
their results to other methods.

Please contact ismailemrekartoglu at gmail.com if you have any questions/suggestions.

