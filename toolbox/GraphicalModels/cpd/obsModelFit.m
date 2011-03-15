function [model] = obsModelFit(X, Y, obstype)
% Fit a model of the form Xj -> Yj
% where X(i,j) is discrete value of node j in case i
% and Y(i,j,:) is a feature vector
% There are several types of obs model.
% - 'gauss': we fit a model to the features
%   p(Y(i,j,:)|X(i,j)=k) = gauss(mu(:,j,k), Sigma(:,:,j,k)
% - 'quantize': we discretize Y(i,j) and fit a model of the form
%    p(Y(i,j)=b | X(i,j)=k) = T(j,k,b), sum_{b=1}^B = 1
%    where B = num bins
%  - 'localev':  Y(i,j,k) = p(X(i,j)=k|evidence)
%   If Y is just 2d, we assume  Y(i,j) = p(X(i,j)=on|evidence) for binary X
%
% The purpose of the localev obstypes is if some external
% process has already transformed the features into probabilities.
% We still want to treat this data like any other feature,
% so we can potentially recalibrate it.
%
 
% This file is from pmtk3.googlecode.com

[Ncases Nnodes Ndims] = size(Y); %#ok

X = canonizeLabels(X);
model.obsType = obstype;
Nstates = nunique(X(:));
model.Nstates = Nstates;
model.Ndims = Ndims;
model.Nnodes = Nnodes;
switch obstype
  case {'localev'}
   % no-op
  case 'quantize'
    if Ndims > 1
      error('we currently only quantize 1d features')
    end
    model.Nbins = 10;
    %YQ = quantizePMTK(Y, 'levels', model.Nbins, 'method', 'uniform');
    [YQ, model.discretizeParams] = discretizePMTK(Y, model.Nbins);
    model.CPT = zeros(Nstates, model.Nbins, Nnodes);
    for j=1:Nnodes
      cnt = computeCounts([ X(:,j) YQ(:,j) ], [Nstates model.Nbins]); % parent then child
      dirichlet = 0.1; % smoothing parameter
      prior  = (dirichlet/numel(cnt))*onesPMTK(size(cnt)); %BDeu
      model.CPT(:,:,j) = mkStochastic(cnt+prior);
    end
  case 'gauss'
    model.mu = zeros(Ndims,  Nstates, Nnodes);
    model.Sigma = zeros(Ndims, Ndims, Nstates, Nnodes);
    for j=1:Nnodes
      Z = canonizeLabels(X(:,j)); %
      Yj = squeeze(Y(:,j,:)); % Y(case,dim)
      for k=1:Nstates
        ndx = (Z==k);
        model.mu(:, k, j) = mean(Yj(ndx,:));
        model.Sigma(:,:,k,j) = shrinkcov(Yj(ndx,:));
      end
    end
  %[model.localCPDs, model.localCPDpointers, ...
  %  model.localMu, model.localSigma] = ...
   % condGaussCpdMultiFit(X, Y, Nstates);
end

end

