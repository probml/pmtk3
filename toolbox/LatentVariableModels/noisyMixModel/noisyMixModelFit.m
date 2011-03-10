function [model] = noisyBinaryMixFit(X, Y, K)
% Mix model of form Q -> Xj -> Yj
% similar to a tied mixture (semi-continuous) HMM
% p(X,Y|Q=k) = prod_j p(Xj|Q=k)  p(Yj|Xj)
% p(Xj|Q=k) Ber(xj|theta(j,k)) 
% p(Yj|X=c) = Gauss(y(:,j) | mu(j,c), Sigma(j,c))
%
% The idea is that Xj is the j'th binary tag
% Yj is the scalar feature vector for that tag
%
% X is Ncases*Nnodes discrete {1..K} (or {0,1})
% Y is Ncases * Nnodes * Ndims
% so Y(i,j,:) are the observations for node j in case i
% K is num mixture components

% This file is from pmtk3.googlecode.com

[Ncases Nnodes Ndims] = size(Y); %#ok

% Fit p(y|x)
Nstates = nunique(X(:));
[model.obsmodel.localCPDs, model.obsmodel.localCPDpointers] = ...
  condGaussCpdMultiFit(X, Y, Nstates);
model.obsmodel.Nstates = Nstates;
model.obsmodel.Ndims = Ndims;

% Fit p(x|Q) - see mixBerMnistEM
options = {'maxIter', 10, 'verbose', true};
X = canonizeLabels(X);
model.mixmodel  = mixModelFit(X, K, 'discrete', options{:});
model.Nstates = Nstates;
model.Nnodes = Nnodes;
end

