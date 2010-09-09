function model = markovFit(X, nstates, pseudoCountsPi, pseudoCountsA)
% Fit a markov model via MLE/MAP.
% X(i, :) is the ith case and X(i, j) is in 1:nstates.
%
% Returns a struct with fields pi, A.
%
% pi(j) = p(S(1) = j)
% A(i, j) = p(S(t) = j | S(t-1) = i)
%
% where S(t) denotes the state at time step t.
%

% This file is from pmtk3.googlecode.com


if nargin < 2, nstates = nunique(X(:)); end
if nargin < 3, pseudoCountsPi = ones(1, nstates); end
if nargin < 4, pseudoCountsA  = ones(nstates, nstates); end

if size(pseudoCountsA, 1) ~= size(pseudoCountsA, 2)
    pseudoCountsA = repmat(rowvec(pseudoCountsA), 1, nstates);
end

N = size(X, 1);

%%
model.pi = rowvec(normalize(histc(X(:, 1), 1:nstates)) + rowvec(pseudoCountsPi - 1));
counts = zeros(nstates, nstates);
for i=1:N
    counts = counts + ...
        accumarray([X(i, 1:end-1)', X(i, 2:end)'], 1, [nstates, nstates]);
end
model.A = normalize(counts + pseudoCountsA - 1, 2);
end
