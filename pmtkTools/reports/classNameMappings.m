function [basic, supervised, latent, graphical] = classNameMappings()
%% This file stores the mapping from classname to group name. 
% It needs to be manually updated when new models are created. 

% This file is from pmtk3.googlecode.com



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
    'mixexp'
    'mlp'
    'naiveBayes'
    'oneVsRestClassifier'
    'probitReg'
    'rvm'
    'smlr'
    'svm'    
    };

latent =     {
  'deepBelNet'
    'hmm'
    'lds'
    'mixGaussBayes'
    'mixGaussDiscrete'
    'mixtureModel'
    'ppca'  
    'rbm'
    };

graphical =  {
    'crf2'
    'dgm'
    'dgmSeq'
    'ggm'
    'mrf'
    'mrf2'
    'tree'   };




end
