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
    'mlpClassif'
    'mlpRegress'
    'naiveBayes'
    'probitReg'
    'svm'    };

latent =     {
    'hmm'
    'lds'
    'markov'
    'mixDiscrete'
    'mixGauss'
    'mixGaussDiscrete'
    'mixGaussVb'
    'mixStudent'
    'ppca'   };

graphical =  {
    'crf2'
    'dgm'
    'ggm'
    'mrf'
    'mrf2'
    'tree'   };




end