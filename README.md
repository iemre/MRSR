[![DOI](https://zenodo.org/badge/18878/iemre/MRSR.svg)](https://zenodo.org/badge/latestdoi/18878/iemre/MRSR)

This folder contains some files of MATLAB code used for the experiments in the M.Sc. thesis titled "A Recommender System Based on Sparse Dictionary Coding" by Ismail Emre Kartoglu (King's College London, 2014)

MRSR is a set of MATLAB classes for recommender systems research.
The idea is to gather all the recommender system algorithms and make reliable comparisons.
The user can test their own algorithm by inheriting the AbstractExperiment class and implementing the abstract methods.
Example use cases are described in what follows.

# License
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

Recommender systems out of the box
==================================
1) A predictive recommender based on sparse dictionary coding.

2) A top-n recommender based on sparse dictionary coding.

3) A predictive recommender based on k-NN.

4) A top-n recommender based on k-NN.

5) A predictive recommender based on the matrix factorisation method introduced by Koren et al.

6) A random recommender (to check a given recommender does not perform worse than a random recommender!).

7) MaxF top-n recommender (simply recommends the top-hit items to every user, works surprisingly well on some metrics).

Important notes: 
=======================
1) To be able to run a sparse coder experiment, the user must download the sparse coders encapsulated by the SparseCoder.m file.

   The user can download an implementation of the PC/BC-DIM algorithm using this link: http://www.inf.kcl.ac.uk/staff/mike/Code/sparse_classification.zip 

   SolveDALM.m, SolveFISTA.m, SolveOMP.m, SolvePFP.m, and SolveSpaRSA.m files can be downloaded using the following web pages (24/08/2014):

   http://www.eecs.berkeley.edu/~yang/software/l1benchmark/
   http://sparselab.stanford.edu/

   **Update:** PC/BC-DIM and PFP algorithms are now included in this project. 

2) To run the unit tests, run the "runalltests.m" matlab file. Matlab's xUnit unit test library might need to be installed.

Example 1 - Using the item-based KNN recommender:
==========================================================
```
test = ItemBasedKNN.createNewWithDatasets(baseSet, testSet)
test.k = 10
test.setSimilarityCalculatorTo(Similarity.COSINE);
test.calculatePredictiveAccuracy; % calculate MAE and RMSE
numberOfUsers = 943;
test.showPrecisionAndRecall(10, [1:numberOfUsers)]
```

Here ```baseSet``` is the training set (User-Item matrix), and ```testSet``` is the test User-Item matrix (ratings removed from the training set). 

Example 2 - Using the item-based sparse coding recommender:
==========================================================
```
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
```


To measure the performance of the user's own algorithm:
==========================================================

Create a class, make it inherit the AbstractExperiment class, and implement the following abstract methods in AbstractExperiment class:
```
       % Generate a top-n list for the given user. The list may contain
       % an item that is already rated in the base (training) set.
       topNList = generateTopNListForUser(obj, n, userIndex); 
       
       % Geneate a top-n list for the given user. The list may contain
       % only the unrated items (Items that are not rated in the base (training) set.
       topNList = generateTopNListForTestSetForUser(obj, n, userIndex);
       
       % Predict the rating of the given user userIndex for the item with itemIndex.
       prediction = makePrediction(obj, userIndex, itemIndex);
       
       % Make initial calculations. This may be similarity matrix
       % calculation for k-NN algorithm, or sparse reconstruction for
       % sparse coding. Some of the evaluation methods call this
       % function before they start their job. The user may leave this method
       % empty. They may instead choose to add their initialization logic (if any)
       % to other methods such as generateTopNListForTestSetForUser.
       initialize(obj);       
```
After implementing these methods, the user can measure the personalisation, CPP, recall, precision, MAE and RMSE of their own algorithm and safely compare 
their results to other methods. Please see the SampleRecommender.m file (https://github.com/iemre/MRSR/blob/master/SampleRecommender.m) as an example. 

Please contact <img src="email.png" alt="email" style="width: 260px; height:23px;"/> if you have any questions/suggestions.

