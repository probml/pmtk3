function [W, Z, evals, Xrecon, mu, iter] = pcaFitEm(X, k, varargin)
%% Principal component analysis using EM
%
%% Inputs
% X      - n*d - rows are examples, columns are features
%
% If k is not specified, we use the maximum possible value (rank(X))
%
% * See emAlgo for additional EM related inputs
%% Outputs
% W      -  d*k (the basis vectors)
% Z      -  n*k (the principal components)
% evals  -  the eigenvalues
% Xrecon -  n*d - reconstructed from first K
% mu     -  d*1
%%

% This file is from pmtk3.googlecode.com

n = size(X, 1);
SetDefaultValue(2, 'k', rank(X)); 
mu = mean(X);
X = X - repmat(mu, n, 1);
X = X'; % each *column* is now a centered data case
%%
model.k = k;
[model, negMseHist] = emAlgo(model, X, @init, @estep, @mstep, varargin{:});
iter = length(negMseHist);
W = model.W;
%% post process
W = orth(W);
X = X';
Z = X*W; % rows of Z are cases
% do usual pca on Z in O(k^3) time
[evecs, evals] = eig(Z'*Z/n);
[evals, perm] = sort(diag(evals), 'descend');
evecs = evecs(:, perm);
W = W*evecs;
Z = X*W;
Xrecon = Z*W' + repmat(mu, n, 1);
end

function model = init(model, X, restartNum) %#ok
k = model.k; 
model.W = rand(size(X, 1), k);
end

function [ess, negmse] = estep(model, X)
W = model.W;
Z = W \ X;
Xrecon = W*Z;
negmse = -mean((Xrecon(:) - X(:)).^2);
ess.Z = Z;
ess.XZ = (X*Z'); 
end

function model = mstep(model, ess)
Z = ess.Z;
model.W = (ess.XZ)/(Z*Z');
end
