function model = mlpFit(X, y, varargin)
% Multi-layer perceptron for classification and regression
%% INPUTS: (specified as name value pairs)
% nHidden       ... Number of hidden units. Can be a vector.
% regType       ... 'L1' or 'L2' or 'none'
% nclasses      ... the number of output classes
% lambda        ... regularizer 
% fitOptions    ... optional args (a struct) passed to minfunc
% preproc       ... a struct, passed to preprocessorApplyToTtrain
% method        ... schmidt (default) or netlab 
% outputType    ... regression, binary or multiclass (inferred from y)
%% OUTPUTS:
% model         ... a struct, which you can pass directly to logregPredict
% X             ... possibly transformed input
% lambdaVec     ... vector of regularizers, including 0 for offset
% opt           ... output of optimizer 
%%
%
% schmidt method only handles regression and binary responses.
% netlab method only handles single hidden layer.

% This file is from pmtk3.googlecode.com


y = y(:);
assert(size(y, 1) == size(X, 1));

K = nunique(y);
if K <= 2
    [y, ySupport] = setSupport(y, [-1 1]);
    outputType = 'binary';
elseif isequal(y, round(y))
    [y, ySupport] = setSupport(y, 1:K);
     outputType = 'multiclass';
else
    ySupport = [];
    outputType = 'regression';
end

args = prepareArgs(varargin); % converts struct args to a cell array
[   nclasses      ...
  regType       ...
  lambda       ...
  preproc      ...
  fitOptions    ...
  method         ...
  nHidden       ...
  outputType    ...
  ] = process_options(args    , ...
  'nclasses'      , nunique(y), ...
  'regType'       , 'l2'    , ...
  'lambda'        ,  0       , ...
  'preproc'       ,  preprocessorCreate('addOnes', false, 'standardizeX', true)       , ...
  'fitOptions'    , struct('Display', 'none'), ...
  'method'        , 'schmidt', ...
  'nHidden'       , [], ...
  'outputType'    , outputType);

if ~strcmpi(regType, 'l2')
  error('mlpFit currently only supports L2 regularization')
end


[preproc, X] = preprocessorApplyToTrain(preproc, X);

switch lower(method)
  case 'schmidt'
    switch outputType
      case 'binary'
        model = mlpClassifFitSchmidt(X, y, nHidden, lambda, fitOptions);
      case 'multiclass'
        error('schmidt method does not support %d classes', nclasses)
      case 'regression'
        model = mlpRegressFitSchmidt(X, y, nHidden, lambda, fitOptions);
    end
    
  case 'netlab'
    if length(nHidden)  > 1  
      error('netlab method does not support %d hidden layers', length(nHidden))
    end
    switch outputType
      case 'binary'
        [model, output] = mlpGenericFitNetlab(X, y, nHidden, ...
          lambda, fitOptions, 'logistic');
      case 'multiclass'
        [model, output] = mlpGenericFitNetlab(X, y, nHidden, ...
          lambda, fitOptions, 'softmax');
      case 'regression'
        [model, output] = mlpGenericFitNetlab(X, y, nHidden, ...
          lambda, fitOptions, 'linear');
    end
  otherwise
    error(['method ' method ' not supported'])
end

model.preproc = preproc;
model.type = 'mlp';
model.method = method;
model.outputType = outputType;
model.ySupport = ySupport;

end
