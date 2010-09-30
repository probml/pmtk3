function [mu, assign, errHist] = kmeansFit(X, K, varargin)
% Hard cluster data using kmeans.
%
%% Inputs
%
% X          ...   X(i, :) the ith data case
% K          ...   the number of clusters to fit
%% Outputs
%
% mu         ...   mu(:, k) is the k'th center
% assign     ...   assign(i) is the cluster to which data point i is 
%                  assigned.
%% Optional (named) Inputs
%
% 'maxIter'  ...   [100] maximum number of iterations to run
% 'thresh'   ...   [1e-3] convergence threshold 
% 'plotFn'   ...   @plotfn(X, mu, assign, err, iter) called each iteration 
% 'verbose'  ...   [false] if true, display progress each iteration 
% 'mu'       ...   initial guess for the cluster centers
%% Example
% 
% [mu, assign, errHist] = kmeansFit(randn(1000, 10), 7, 'verbose', true);
% 
%% Parse inputs

% This file is from pmtk3.googlecode.com

[maxIter, thresh, plotfn, verbose, mu] = process_options(varargin, ...
    'maxIter' , 100           , ...
    'thresh'  , 1e-3          , ... 
    'plotfn'  , @(varargin)[] , ... % default does nothing
    'verbose' , false         , ...
    'mu'      , []            );    
[N,D] = size(X);
%% Initialize
%  Initialize using K data points chosen at random
if isempty(mu)
    perm = randperm(N);
    % in the unlikely event of a tie,
    % we want to ensure the means are different.
    v = var(X);
    noise = gaussSample(zeros(1, length(v)), 0.01*diag(v), K);
    mu   = X(perm(1:K), :)' + noise';
end
%% Setup loop
iter    = 1;
errHist = zeros(maxIter, 1);
prevErr = Inf; 
while true
    dist   = sqDistance(X, mu'); % dist(i, j) = sum((X(i, :)- mu(:, j)').^2)
    assign = minidx(dist, [], 2); 
    mu     = partitionedMean(X, assign, K)';
    currentErr = sum(min(partitionedSum(dist, assign, K), [], 2)) / N;
    %% Display progress
    errHist(iter) = currentErr;
    plotfn(X, mu, assign, currentErr, iter); 
    if verbose, fprintf('iteration %d, err = %f\n', iter, currentErr); end
    %% Check convergence
    if convergenceTest(currentErr, prevErr, thresh)  ||  (iter >= maxIter)
        break
    end
    iter = iter + 1;
    prevErr = currentErr; 
end
errHist = errHist(1:iter);
end
