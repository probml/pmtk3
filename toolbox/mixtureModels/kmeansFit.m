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
% 'thresh'   ...   1e-3  convergence threshold 
% 'plotFn'   ...   @plotfn(X, mu, assign, err, iter) called each iteration 
% 'verbose'  ...   [false] if true, display progress each iteration 
% 'mu'       ...   initial guess for the cluster centers
%% Example
% 
% [mu, assign, errHist] = kmeansFit(randn(1000, 10), 7, 'verbose', true);
% 
%% Parse inputs
[maxIter, thresh, plotfn, verbose, mu] = process_options(varargin, ...
    'maxIter' , 100           , ...
    'thresh'  , 1e-3          , ... 
    'plotfn'  , @(varargin)[] , ... 
    'verbose' , false         , ...
    'mu'      , []            );    
N = size(X, 1);
%% Initialize
%  Initialize using K data points chosen at random
if isempty(mu)
    perm = randperm(N);
    mu   = X(perm(1:K), :)';
end
%% Setup loop
iter    = 1;
errHist = zeros(maxIter, 1);
while true
    dist   = sqDistance(X, mu'); % dist(i, j) = sum((X(i, :)- mu(:, j)').^2)
    assign = minidx(dist, [], 2); 
    mu     = partitionedMean(X, assign, K)';
    err    = sum(min(partitionedSum(dist, assign, K), [], 2)) / N;
    %% Display progress
    errHist(iter) = err;
    plotfn(X, mu, assign, err, iter); 
    if verbose, fprintf('iteration %d, err = %f\n', iter, err);  end
    %% Check convergence
    if iter > 1 && (convergenceTest(err, errHist(iter-1), thresh) ...
                ||  iter >= maxIter)
        break
    end
    iter = iter + 1;
end
errHist = errHist(1:iter);
end