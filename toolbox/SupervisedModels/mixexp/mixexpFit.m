function [model, loglikHist] = mixexpFit(X, y, nmix, varargin)
%% Fit a mixture of experts model via MLE/MAP using EM
% If the response y is real-valued, we use linear regression experts.
% If the response y is categorical, we use logistic regression experts.
%
% Inputs
%
% X     - X(i, :) is the ith case, i.e. data is of size n-by-d
% y     - y(i) can be real valued or in {1..C}
% nmix     - the number of mixture components to use
%
%
% Optional inputs
% EMargs - cell array. See emAlgo. (Default {})
% fixmix - if true, mixing weights are constants independent of x
%            (default false)
% nclasses - needed if not all labels are present in y
%             (default nunique(y))
% preproc - a struct, passed to preprocessorApplyToTtrain
%                      By default, this adds ones and standardizes
% gatingFitArgs - cell array, default {'lambda', 0.001}
% expertFitArgs - cell array, default {'lambda', 0.001}
%
% Outputs
% 
% A structure - see mixExpCreate for field descriptions
% loglikHist  - a record of the log likelihood at each EM iteration. 
%% 

% This file is from pmtk3.googlecode.com

pp = preprocessorCreate('addOnes', true, 'standardizeX', true);


[EMargs, fixmix, nclasses, preproc, gatingFitArgs, expertFitArgs] = ...
  process_options(varargin, ...
  'EMargs', {}, 'fixmix', false, 'nclasses', [], 'preproc', pp, ...
  'gatingFitArgs', {'lambda', 0.001}, ...
  'expertFitArgs', {'lambda', 0.001});

[preproc, X] = preprocessorApplyToTrain(preproc, X);

% We use k=1:nmix to index mixture components
% and c=1:C to index output classes

[N,D] = size(X);
%X = standardize(X);
%X = [ones(N,1) X];
%D = D+1;
if isequal(y, round(y))
  model.classifier = true;
  if isempty(nclasses)
    nclasses = numel(unique(y));
  end
else
  model.classifier = false;
  nclasses = 1;
end
data.X = X;
data.y = y;
model.nmix = nmix;
model.nclasses = nclasses;
model.D = D;
model.preproc = preproc;
model.expertFitArgs = expertFitArgs;
model.gatingFitArgs = gatingFitArgs;
model.fixmix = fixmix;
model.modelType = 'mixexp';

[model, loglikHist] = emAlgo(model, data, @initFn, @estep, @mstep, ...
  EMargs{:});
                                              
end

function model = initFn(model, data, r) %#ok
nmix = model.nmix; D = model.D; C = model.nclasses;
if model.classifier 
  model.Wy = 0.1*randn(D,C,model.nmix);
else
  model.Wy = 0.1*randn(D,nmix);
  model.sigma2 = 0.1*rand(1,nmix);
end
if model.fixmix
  model.mixweights = normalize(rand(1,nmix));
else
  model.Wq = 0.1*randn(D,nmix);
end
end



function [ess, ll] = estep(model, data)
X = data.X; y = data.y;
N = size(X,1); K = model.nmix;
if model.fixmix
  logprior = repmat(rowvec(log(model.mixweights)), N, 1);
else
  logprior = softmaxLog(X, model.Wq);
end
loglik = zeros(N,K);
if ~model.classifier
  for k=1:K
    loglik(:,k) = gaussLogprob(X*model.Wy(:,k), model.sigma2(k), y);
  end
else
  for k=1:K
    logpred = softmaxLog(X, model.Wy(:,:,k)); % N*C
    %loglik(:,k) = logpred(:, y); % pluck out correct columns
    loglik(y == k,k) = logpred(y == k,k); 
  end
end
logpost = loglik + logprior;
[logpost, logZ] = normalizeLogspace(logpost);
ll = sum(logZ);
post = exp(logpost);
ess.data = data;
ess.post = post;
end
 
function model = mstep(model, ess)

X = ess.data.X; y = ess.data.y;
N = size(X,1);
r = ess.post; % responsibilities
if model.fixmix
  model.mixweights = sum(r,1)/N;
else
  [WqModel] = logregFit(X, r, 'preproc', [], ...
    'nclasses', model.nclasses, model.gatingFitArgs{:});
  model.Wq = WqModel.w;
end


if ~model.classifier
  % weighted least squares
  K = model.nmix;
  D = size(X,2);
  for k=1:K
    expert = linregFit(X, y, 'preproc', [], 'weights', r(:,k), ...
       model.expertFitArgs{:});
    model.Wy(:,k) = expert.w;
    model.sigma2(k) = expert.sigma2;
    %{
    Rk = diag(r(:,k));
    RRk = sqrt(Rk);
    model.Wy(:,k) = (RRk*X) \ (RRk*y);
    yhat = X*model.Wy(:,k);
    rk = sum(r(:,k));
    if rk==0
      model.sigma2(k) = eps;
    else
      model.sigma2(k) = sum(r(:,k) .* (y-yhat).^2) / sum(r(:,k));
    end
    assert(~isnan(model.sigma2(k)))
    assert(model.sigma2(k)>0)
    %}
  end
else
  % weighted logreg 
  K = model.nmix;
  D = size(X,2);
  for k = 1:K
    Rk = diag(round(r(:,k)));
    %model_k = logregFit(Rk*X, y, 'preproc', [],   'nclasses', model.nclasses, ...
    %                    model.expertFitArgs{:});
    model_k = logregFit(X, y, 'preproc', [],   'nclasses', model.nclasses, ...
                        'weights', r(:,k), model.expertFitArgs{:});
    model.Wy(:,:,k) = model_k.w;
  end
  
end
end
