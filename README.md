# EEG-Eye-Blink-Artifact-Removal
This repository contains code about the project of removing eye-blink artifacts in EEG signals in the course Estimation and Detection


The main function runs the project entirely-
1. estimating the filter on the training set,
2.  finding the eye-blinks via a detector,
3.   applying the filter on the test data
4.   computing the performance metrics on both train and test data.
5.   It also plots the estimated eye-blink signal, and the EEG signal both before and after removing eye-blinks for both training and test data. 

The remaining functions are called within the main function to perform various steps like stacking the data, computing the covariance matrices, computing the filter according to the SNR groups (as described in the report), applying the filter and plotting them. Similarly, the detector runs on the test data before performing the same steps. The training and testing data metrics are calculated in TrainSetEvaluation and TestSetEvaluation respectively.


