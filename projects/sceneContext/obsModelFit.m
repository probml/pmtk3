function [model] = obsModelFit(X, Y, obstype)
% Fit a model of the form Xj -> Yj
% where X(i,j) is discrete value of node j in case i
% and Y(i,j,:) is a feature vector
% There are several types of obs model.
% - 'gauss': we fit a model to the features
%   p(Y(i,j,:)|X(i,j)=k) = gauss(mu(:,j,k), Sigma(:,:,j,k)
%  - 'localev':  Y(i,j,k) = p(X(i,j)=k|evidence)
%   If Y is just 2d, we assume  Y(i,j) = p(X(i,j)=on|evidence) for binary X
%
% The purpose of the localev obstypes is if some external
% process has already transformed the features into probabilities.
% We still want to treat this data like any other feature,
% so we can potentially recalibrate it.

% This file is from pmtk3.googlecode.com

[Ncases Nnodes Ndims] = size(Y); %#ok

model.obsType = obstype;
Nstates = nunique(X(:));
model.Nstates = Nstates;
model.Ndims = Ndims;
model.Nnodes = Nnodes;
switch obstype
  case {'localev', 'localev1'}
   % no-op
  case 'gauss'
  [model.localCPDs, model.localCPDpointers, ...
    model.localMu, model.localSigma] = ...
    condGaussCpdMultiFit(X, Y, Nstates);
end

end

