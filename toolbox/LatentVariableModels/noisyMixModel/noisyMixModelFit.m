function [model] = noisyMixModelFit(X, Y, K, obstype)
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

if nargin < 4, obstype = 'gauss'; end

[Ncases Nnodes] = size(X);
[Ncases2 Nnodes2 Ndims] = size(Y); %#ok
Nstates = nunique(X(:));

% Fit p(x|Q) - see mixBerMnistEM
options = {'maxIter', 20, 'verbose', true, 'alpha', 1};
X = canonizeLabels(X);
model.mixmodel  = mixDiscreteFit(X, K,  options{:});
model.Nstates = Nstates;
model.Nnodes = Nnodes;

if isempty(Y), return; end

% Fit p(y|x)
model.obsmodel.obsType = obstype;
model.obsmodel.Nstates = Nstates;
switch obstype
  case 'localev'
   % no-op
  case 'gauss'
  [model.obsmodel.localCPDs, model.obsmodel.localCPDpointers, ...
    model.obsmodel.localMu, model.obsmodel.localSigma] = ...
    condGaussCpdMultiFit(X, Y, Nstates);
  model.obsmodel.Ndims = Ndims;
end


end

