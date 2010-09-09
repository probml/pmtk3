function model = discreteCreate(T)
%% Create a discrete distribution
% PMTKdefn discrete(x | \theta)
%     d       - the number of distributions, i.e. size(X, 2)
%     K       - the number of states, i.e. nunique(X)
%     T       - a K-by-d stochastic matrix, (each *column* represents a
%               different distribution).

% This file is from pmtk3.googlecode.com

[K, d] = size(T); 
model = structure(T, K, d);
model.modelType = 'discrete'; 
end
