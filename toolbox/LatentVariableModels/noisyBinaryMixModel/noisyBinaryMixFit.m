function [model] = noisyBinaryMixFit(X, obs, K)
% Mix model of form Q -> Xj -> Yj
% p(X,Y|Q=k) = prod_j p(Xj|Q=k)  p(Yj|Xj)
% p(Xj|Q=k) Ber(xj|theta(j,k)) 
% p(Yj|X=c) = Gauss(y(:,j) | mu(j,c), Sigma(j,c))
%
% The idea is that Xj is the j'th binary tag
% Yj is the scalar feature vector for that tag
%
% X is Ncases*Nnodes discrete {1..K} (or {0,1})
% obs is Ncases * Nnodes * Ndims
% so obs(i,j,:) are the observations for node j in case i
% K is num mixture components

% This file is from pmtk3.googlecode.com

[Ncases Nnodes Ndims] = size(obs); %#ok

% Fit p(y|x)
[model.obsmodel.localCPDs, model.obsmodel.localCPDpointers] = ...
  condGaussCpdMultiFit(X, obs, Nstates);

% Fit p(x|Q) - see mixBerMnistEM
options = {'maxIter', 10, 'verbose', true};
X = canonizeLabels(X);
model.mixmodel  = mixModelFit(X, K, 'discrete', options{:});
  

end

