function [ model ] = logregFitL2Dual( X, y, lambda, varargin)
%  L2-regularized logistic regression model in the dual space

% This file is from pmtk3.googlecode.com


%PMTKauthor Hannes Bretschneider

[R, V, pp] = process_options(varargin, ...
  'R', [], 'V', [], 'preproc', ...
  preprocessorCreate('standardizeX', true, 'addOnes', true));

if isempty(R)||isempty(V)
    [U S V] = svd(X, 'econ');
    R = U*S;
end

%X = R*V';
[D N] = size(V); %#ok
pre = logregFit(R, y, 'lambda', lambda,...
     'regType', 'L2', 'preproc', pp);
model.preproc.addOnes = pre.preproc.addOnes;
model.binary = pre.binary;
model.ySupport = pre.ySupport;
model.w = [pre.w(1,:); V*pre.w(2:N+1,:)];
%[X, model.Xmu]   = center(X);
%[X, model.Xstnd] = mkUnitVariance(X);
            
end

