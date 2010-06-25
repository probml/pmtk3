function [model, loglikHist] = mixDiscreteFit(X, nmix,  varargin)
%% Fit a mixture of products of discrete distributions via EM.
%
%% Inputs
% X(i, j)   - is the ith case from the jth distribution, an integer in 1...C
% nmix      - the number of mixture components to use
%
%% Optional (named) Inputs
% 'saveMemory'  - it true, (default = false) slower more memory efficient
%               code is run. Use this if you get out of memory errors. 
%
%
%%
% *** See emAlgo() for optional EM related arguments ***
%
%% Outputs
% Returns a struct with fields
%    model.T(c,d,j) = p(xd=c|z=j) nstates*ndistributions*nmixtures
% loglikHist - log likelihood history
[model, loglikHist] = mixDiscreteFitEm(X, nmix,  varargin{:});
end