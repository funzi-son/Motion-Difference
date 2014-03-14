MotionModeling
==============

The code is partially extracted from project of Modeling Human Actions in video. 

+ RBM with Gaussian visible layer
+ Naive Bayes
+ Simple pLSA (Thanks to Emmanouil Benetos)
+ Motion difference data from Weizmann 
+ Action recognition pipeline:
  Video--extract Motion Difference (MD)-- Learn MD features using Gaussian RBM -- K-NN to quantize visual words -- Learn classifiers (Naive Bayes/pLSA)

Future work:
+ Difference Motion Temporal RBM for Humen Action Modeling
