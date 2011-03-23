function [model, loglikTrace] = catFAfit(data, Dz, varargin)
% We can specify one or more data types:
% data.continuous: Dc * N
% data.binary:     Db * N
% data.discrete:   Dm * N, data.discrete(j,n) in {1..data.nClass(j)}
% Any location can be NaN, meaning missing value
%
% Dz is the number of latent factors
% nClass(j) is the number of categories for discrete variable 
%
% loglikTrace(t) is lower bound on loglik at iteration t

[maxIter, nClass] = process_options(varargin, 'maxIter', 500, ...
  'nclass', nunique(data.discrete, 2));

model.nClass = nClass;
% cata.categorical: Dm*sum(nclass-1) * N
data.categorical = encodeDataOneOfM(data.discrete, nClass);

 
  
opt=struct('Dz', Dz, 'nClass', nClass, 'initMethod', 'random');
[params0, data] = initMixedDataFA(data, [], opt);
% prior for noise variance
params0.a = 1;
params0.b = 1;
params0.lambda = 0.01; % L2 regularization for regression weights
options = struct('maxNumOfItersLearn', maxIter,  'lowerBoundTol', 1e-6, ...
  'estimateBeta', 1, 'estimateMean', 1, 'regCovMat',0, 'estimateCovMat',0, 'display', true);

[Dc,N] = size(data.continuous);
[Dm,Nm] = size(data.discrete);
[Db,bm] = size(data.binary);

missing = any(isnan(data.discrete(:))) || any(isnan(data.binary (:))) || ...
  any(isnan(data.continuous(:)));
if missing
  funcName = struct('inferFunc', @inferMixedDataFA_miss, 'maxParamsFunc', @maxParamsMixedDataFA);
else
  % the non missing version is slightly faster
  if (Dm+Db)==0
    funcName = struct('inferFunc', @inferFA, 'maxParamsFunc', @maxParamsFA);
  else
    funcName = struct('inferFunc', @inferMixedDataFA, 'maxParamsFunc', @maxParamsMixedDataFA);
  end
  
end

[params, loglikTrace] = learnEm(data, funcName, params0, options);
model.params = params;

 
  
end
