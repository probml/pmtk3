function [model, loglikHist] = mixModelFitEm(data, nmix, type, varargin)
%% Fit a mixture model via EM
% See mixModelFit
% 
%
%%
[initParams, prior, mixPrior, overRelaxFactor, EMargs] = ...
    process_options(varargin, ...
    'initParams'        , [], ...
    'prior'             , [], ...
    'mixPrior'          , [], ...
    'overRelaxFactor'   , []);
%%
[n, d]      = size(data);
model.type  = type;
model.nmix  = nmix;
model.d     = d;
mstepOrFn   = [];
if isempty(mixPrior)
    model.mixPrior = 2*ones(1, nmix);
end
if ischar('none') && strcmpi(mixPrior, 'none'); 
    model.mixPrior = ones(1, nmix);
    model.mixPriorFn = @(m)0;
else
    model.mixPriorFn  = @(m)log(m.mixWeight(:))'*(m.mixPrior(:)-1);
end
if isscalar(model.mixPrior)
    model.mixPrior = repmat(model.mixPrior, 1, nmix); 
end
switch lower(type)
    case 'gauss'
        if ~isempty(overRelaxFactor);
            mstepOrFn = @mstepGaussOr;
        end
        initFn  = @(m, X, r)initGauss   (m, X, r, initParams, prior);
    case 'discrete'
        initFn  = @(m, X, r)initDiscrete(m, X, r, initParams, prior);
    case 'student'
        initFn  = @(m, X, r)initStudent (m, X, r, initParams, prior);
end
[model, loglikHist] = emAlgo(model, data, initFn, @estep, @mstep, ...
    'mstepOR', mstepOrFn , 'overRelaxFactor' , overRelaxFactor, EMargs{:});
end

%% Initialization
function model = initGauss(model, X, restartNum, initParams, prior)
%% Initialize 
nmix = model.nmix; 
if restartNum == 1
    if ~isempty(initParams)
        mu              = initParams.mu;
        Sigma           = initParams.Sigma;
        model.mixWeight = initParams.mixWeight;
    else
        [mu, Sigma, model.mixWeight] = kmeansInitMixGauss(X, nmix);
    end
else
    mu              = randn(d, nmix);
    regularizer     = 2; 
    Sigma           = stackedRandpd(d, nmix, regularizer); 
    model.mixWeight = normalize(rand(1, nmix) + regularizer); 
end
model.cpd = condGaussCpdCreate(mu, Sigma, 'prior', prior);
end

function model = initDiscrete(model, X, restartNum, initParams, prior)
%% Initialize
nObsStates = max(X(:)); 
if restartNum == 1 && ~isempty(initParams)
    T = initParams.T;
    model.mixWeight = initParams.mixWeight;
else
    % randomly partition data, fit each partition separately, add noise.
    nmix    = model.nmix;
    d       = size(X, 2);
    T       = zeros(nObsStates, nmix, d);
    Xsplit  = randsplit(X, nmix);
    for k=1:nmix
        m = discreteFit(Xsplit{k}, 1, nObsStates);
        T(:, k, :) = m.T;
    end
    T               = normalize(T + 0.2*rand(size(T)), 1); % add noise
    model.mixWeight = normalize(10*rand(1, nmix) + ones(1, nmix));
end
model.cpd = condDiscreteProdCpdCreate(T, 'prior', prior); 
end

function model = initStudent(model, X, restartNum, initParams, prior)
%% Initialize
model = initGauss(model, X, restartNum, initParams, prior); 
if ~isempty(initParams)
    dof = initParam.dof;
else
    dof = 10*ones(1, model.nmix); 
end
initCpd   = model.cpd; 
dofEstimator = @(cpd, ess)estimateDofNll(cpd, ess, X, model.mixPrior);
model.cpd = condStudentCpdCreate(initCpd.mu, initCpd.Sigma, dof, ...
    'prior', prior, 'dofEstimator', dofEstimator); 
end

function [ess, loglik] = estep(model, data)
%% Compute the expected sufficient statistics
[weights, ll] = mixModelInferLatent(model, data); 
cpd           = model.cpd;
ess           = cpd.essFn(cpd, data, weights); 
loglik        = sum(ll) + cpd.logPriorFn(cpd) + model.mixPriorFn(model); 
end

function model = mstep(model, ess)
%% Maximize
cpd             = model.cpd;
model.cpd       = cpd.fitFnEss(cpd, ess); 
model.mixWeight = normalize(ess.wsum + model.mixPrior - 1); 
end

%% MstepOR
function [model, valid] = mstepGaussOr(model, modelBO, eta)
%% Over-relaxed Gaussian mstep 
[D, D, nmix] = size(modelBO.Sigma);
% Since weights are constrained to sum to one, we do update in softmax
% parameterization
mixWeight = model.mixWeight.*(modelBO.mixWeight ./ model.mixWeight).^eta;
mixWeight = normalize(mixWeight);
Sigma     = zeros(D, D, nmix);
mu        = zeros(D, nmix);
valid = true;
for c = 1:nmix
    % Regular update
    mu(:, c) = model.mu(:, c) + eta*(modelBO.mu(:, c) - model.mu(:, c));
    %Since Sigma is constrained to positive definite matrices, the updation
    %of Sigma is done in the Log-Euclidean space. (ref: "Fast and Simple
    %Calculus on Tensors in the Log-Euclidean Framework", Vincent Arsigny,
    %Pierre Fillard, Xavier Pennec, and Nicholas Ayache)
    try
        matLogSigma    = logm(model.Sigma(:, :, c));
        matLogSigma_BO = logm(modelBO.Sigma(:, :, c));
        matLogSigma    = matLogSigma + eta*(matLogSigma_BO - matLogSigma);
        Sigma(:, :, c) = expm(matLogSigma);
    catch %#ok
        valid  = false; return;
    end
    if ~isposdef(Sigma(:, :, c))
        valid = false; return;
    end
end
model.mu        = mu;
model.Sigma     = Sigma;
model.mixWeight = mixWeight;
end

function dof = estimateDofNll(cpd, ess, data, mixPrior)
%% Optimize -log likelihood of observed data using gradient free optimizer
wsum        = ess.wsum; 
nmix        = numel(wsum); 
m.mixWeight = normalize(wsum + mixPrior - 1); 
m.cpd       = cpd;
m.nmix      = nmix;
m.type      = 'student';
dofMin      = 0.1;
dofMax      = 1000;
dof         = zeros(1, nmix); 
for k=1:nmix
    dof(k) = fminbnd(@(v)mixStudentNll(m, data, k, v), dofMin, dofMax);
end
end
function out = mixStudentNll(model, X, curK, v)
model.cpd.dof(curK) = v;
out = -sum(mixModelLogprob(model, X));
end