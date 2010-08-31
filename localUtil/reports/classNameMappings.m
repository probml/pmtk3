function [basic, supervised, latent, graphical] = classNameMappings()
%% This file stores the mapping from classname to group name. 
% It needs to be manually updated when new models are created. 


basic =      {
    'beta'
    'betaBinom'
    'binomial'
    'chi2'
    'dirichlet'
    'discrete'
    'gamma'
    'gauss'
    'gaussInvWishart'
    'invChi2'
    'invGamma'
    'invWishart'
    'laplace'
    'markov'
    'multinom'
    'pareto'
    'poisson'
    'student'
    'uniform'
    'wishart'};

supervised = {
    'discrimAnalysis'
    'fisherLda'
    'generativeClassifier'
    'knn'
    'linreg'
    'logreg'
    'mlp'
    'naiveBayes'
    'probitReg'
    'svm'    };

latent =     {
    'hmm'
    'lds'
    'mixModel'
    'mixGaussDiscrete'
    'mixGaussBayes'
    'ppca'   };

graphical =  {
    'crf2'
    'dgm'
    'dgmSeq'
    'ggm'
    'mrf'
    'mrf2'
    'tree'   };




end