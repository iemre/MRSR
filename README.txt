==============================LICENSE====================================
A MATLAB Package for Collaborative Filtering Recommender Systems Research
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


This folder contains some files of MATLAB code used for the experiments in the M.Sc. thesis titled "A Recommender System Based on Sparse Dictionary Coding" by Ismail Emre Kartoglu (2014).

The folder structure is as follows:

/root
	AbstractExperiment.m
	Result.m
	runalltests.m
	UIMatrixUtils.m
	/BaselineRecommender
		-> BaselineRecommender.m
	/KNN
		-> ItemBasedKNN.m
		-> Similarity.m
	/PCA
		-> PCARecommender.m
	/RandomRecommender
		-> RandomRecommender.m
	/SparseCoding
		-> AbstractSparseCoderExperiment.m
		-> ItemBasedSparseCoderExperiment.m
		-> SparseCoder.m
		-> UserBasedSparseCoderExperiment.m
	/tests 



Important note: 
=======================
To be able to run a sparse coder experiment, you must download the sparse coders encapsulated by the SparseCoder.m file.

The user can download the PC/BC-DIM algorithm using this link: http://www.inf.kcl.ac.uk/staff/mike/Code/sparse_classification.zip 

SolveDALM.m, SolveFISTA.m, SolveOMP.m, SolvePFP.m, and SolveSpaRSA.m algorithms/files can be downloaded using the following web pages (24/08/2014):

http://www.eecs.berkeley.edu/~yang/software/l1benchmark/
http://sparselab.stanford.edu/


Example 1 - Using the item-based KNN recommender:
==========================================================
exp = ItemBasedKNN.createNewWithDatasets(baseSet, testSet)
exp.calculateErrorMetrics(Similarity.PEARSON)


Example 2 - Using the item-based sparse coding recommender:
==========================================================
exp = ItemBasedSparseCoderExperiment.createItemBasedExperiment(baseSet, testSet)
exp.calculateErrorByColumnRemoval;
numberOfUsers = 943;
exp.showPrecisionAndRecall(10, [1:numberOfUsers])

