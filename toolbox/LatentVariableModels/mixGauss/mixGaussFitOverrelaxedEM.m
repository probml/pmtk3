function [model, loglikHist] = mixGaussFitOverrelaxedEM(data, nmix,  overRelaxFactor, varargin)
%% Fit a mixture of Gaussian using over-relaxed EM
%
% By default we lightly regularize the parameters, so we are doing map
% estimation. To turn this off, set 'prior' and 'mixPrior to 'none'. See
% Inputs below.
%
%% Inputs
%
% data     - data(i, :) is the ith case, i.e. data is of size n-by-d
% nmix     - the number of mixture components to use
% 'overRelaxFac
% This file is from pmtk3.googlecode.com

[initParams, prior, mixPrior, EMargs] = ...
    process_options(varargin, ...
    'initParams'        , [], ...
    'prior'             , [], ...
    'mixPrior'          , []);

[n, d]      = size(data);
model.type  = 'mixGauss';
model.nmix  = nmix;
model.d     = d;
model       = setMixPrior(model, mixPrior);
initFn = @(m, X, r)initGauss(m, X, r, initParams, prior); 


[model, loglikHist] = emAlgoAdaptiveOverRelaxed...
  (model, data, initFn, @estep, @mstep, @mstepGaussOr, ...
                            'overRelaxFactor' , overRelaxFactor  , ...
                            EMargs{:});
end

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


function [ess, loglik] = estep(model, data)
%% Compute the expected sufficient statistics
[weights, ll] = mixGaussInferLatent(model, data); 
cpd           = model.cpd;
ess           = cpd.essFn(cpd, data, weights); 
ess.weights   = weights; % useful for plottings
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
[D, D, nmix] = size(modelBO.cpd.Sigma);
% Since weights are constrained to sum to one, we do update in softmax
% parameterization
mixWeight = model.mixWeight.*(modelBO.mixWeight ./ model.mixWeight).^eta;
mixWeight = normalize(mixWeight);
Sigma     = zeros(D, D, nmix);
mu        = zeros(D, nmix);
valid = true;

muReg    = model.cpd.mu;
muBO     = modelBO.cpd.mu;
SigmaReg = model.cpd.Sigma;
SigmaBO  = modelBO.cpd.Sigma; 

for c = 1:nmix
    % Regular update
    mu(:, c) = muReg(:, c) + eta*(muBO(:, c) - muReg(:, c));
    %Since Sigma is constrained to positive definite matrices, the updation
    %of Sigma is done in the Log-Euclidean space. (ref: "Fast and Simple
    %Calculus on Tensors in the Log-Euclidean Framework", Vincent Arsigny,
    %Pierre Fillard, Xavier Pennec, and Nicholas Ayache)
    try
        matLogSigma    = logm(SigmaReg(:, :, c));
        matLogSigma_BO = logm(SigmaBO(:, :, c));
        matLogSigma    = matLogSigma + eta*(matLogSigma_BO - matLogSigma);
        Sigma(:, :, c) = expm(matLogSigma);
    catch %#ok
        valid  = false; return;
    end
    if ~isposdef(Sigma(:, :, c))
        valid = false; return;
    end
end
model.cpd.mu    = mu;
model.cpd.Sigma = Sigma;
model.mixWeight = mixWeight;
end

