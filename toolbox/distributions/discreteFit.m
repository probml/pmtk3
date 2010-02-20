function model = discreteFit(X, alpha, weights)
% Fit a discrete distribution, or if X is a matrix, a product of discrete
% distributions. 
%
% X(i, j)        is the ith case, assumed to be from the jth distribution.
%                X must be in 1:K. 
%
% alpha        - dirichlet alpha, i.e. pseudo counts
%                (default is all ones vector - i.e. no prior)
%
% weights      - optionally weight each data case: useful for EM.
%
% model        - a struct with the following fields:
%
%     d       - the number of distributions, i.e. size(X, 2)
%     K       - the number of states, i.e. numel(unique(X))
%     T       - a K-by-d stochastic matrix, (each *column* represents a
%               different distribution).
%
% Example: 
% X = randi(5, [100, 4]);   % categorical data in [1,5] 100 cases, 4 dists
% model = discreteFit(X);
%      OR
% alpha = [1 3 3 5 9];
% model = discreteFit(X, alpha);

    K = max(X(:)); 
    d = size(X, 2);
    if nargin < 3 || isempty(weights)
        counts = histc(X, 1:K); % works even when X is a matrix - no need to loop
    else 
        weights = colvec(weights);
        counts = zeros(K, d);
        for c=1:K 
           counts(c, :) = sum(bsxfun(@times, (X == c), weights), 1);
        end
    end
    if nargin < 2; alpha = 1; end
    model.T = normalize(bsxfun(@plus, counts, colvec(alpha-1)), 1);
    model.K = K;
    model.d = d;
end