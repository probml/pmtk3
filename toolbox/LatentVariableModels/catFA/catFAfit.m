function [model, loglikTrace] = catFAfit(discreteData, ctsData, Dz, varargin)
% We can specify one or more data types:
% discreteData(n, j) in {1..data.nClass(j)}
% ctsData(n, k) in real
% Any location can be NaN, meaning missing value
%
% Dz is the number of latent factors
% nClass(j) is the number of categories for discrete variable 
%
% loglikTrace(t) is lower bound on loglik at iteration t


[maxIter, nClass, verbose] = process_options(varargin, 'maxIter', 100, ...
  'nClass', [], 'verbose', true);

% data.foo stores cases in columns, not rows
data.discrete = discreteData';
data.continuous = ctsData';
data.binary = [];


[Dc,N] = size(data.continuous);
[Dm,Nm] = size(data.discrete);
[Db,bm] = size(data.binary);

if isempty(nClass)
  if Dm ~= 0
    nClass = nunique(data.discrete, 2);
  end
end
model.nClass = nClass;


% cata.categorical: Dm*sum(nclass-1) * N
if ~isempty(data.discrete)
  data.categorical = encodeDataOneOfM(data.discrete, nClass);
end


  
opt=struct('Dz', Dz, 's0', 0.01, 'nClass', nClass, 'initMethod', 'random');
if (Dm+Db)==0 % cts only
  data.categorical = [];
  [params0, data] = initFA(data, [], opt);
else
  [params0, data] = initMixedDataFA(data, [], opt);
end
% prior for noise variance
params0.a = 1;
params0.b = 1;
%params0.lambda = 0.001; % L2 regularization for regression weights
options = struct('maxNumOfItersLearn', maxIter,  'lowerBoundTol', 1e-6, ...
  'estimateBeta', 1, 'estimateCovMat',0, 'display', verbose);

useJaakkola = false;

missing = any(isnan(data.discrete(:))) || any(isnan(data.binary(:))) || ...
  any(isnan(data.continuous(:)));
if missing
  funcName = struct('inferFunc', @inferMixedDataFA_miss, 'maxParamsFunc', @maxParamsMixedDataFA)
else
  % the non missing version is faster
  if (Dm+Db)==0 % cts only
    funcName = struct('inferFunc', @inferFA, 'maxParamsFunc', @maxParamsFA);
  elseif useJaakkola % binary and possibly gaussian
    data.binary = data.discrete;
    data.discrete = [];
    funcName = struct('inferFunc', @inferMixedDataFA_jaakkola, 'maxParamsFunc', @maxParamsMixedDataFA);
  else
    funcName = struct('inferFunc', @inferMixedDataFA, 'maxParamsFunc', @maxParamsMixedDataFA);
  end
  
end


[params, loglikTrace] = learnEm(data, funcName, params0, options);
params.psi = []; % save space - remove params of variational posterior
model.params = params;


  
end
