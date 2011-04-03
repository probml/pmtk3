function [w]=linregFitGroupLasso(X, y, groups, lambda, method)
% Fits the grouped lasso model 

% This file is from pmtk3.googlecode.com

if nargin < 5, method = 'SPG'; end

[N,D] = size(X); %#ok
winit = zeros(D,1);
if isscalar(lambda), lambda=lambda*ones(nunique(groups),1); end
lambda = colvec(lambda); % required by L1GeneralGroup
switch lower(method)
  case 'em',
    [w,sigma,logpostTrace] = linregFitSparseEm(X, y, 'groupLasso', ...
      'lambda', lambda, 'groups', groups);
  case 'spg'
    funObj = @(w)SquaredError(w,X,y);
    options.normType = 2;
    options.verbose = 0;
    %w = L1groupSPG(funObj,winit,lambda,groups,options);
    %w = L1GeneralGroup_Auxiliary(funObj,winit,lambda,groups,options);
    w = L1GeneralGroup_SoftThresh(funObj,winit,lambda,groups,options);
  case 'minconfsep' % deprecated
    w = linregFitGroupLassoMinconfSep(X, y, groups, lambda, winit);
  otherwise
    error(['unknown method ' method])
end
end
