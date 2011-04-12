function [model, loglikHist] = mixGaussFit(data, nmix,  varargin)
%% Fit a mixture of Gaussians via MLE/MAP (using EM)
%
%
%% Inputs
%
% data     - data(i, :) is the ith case, i.e. data is of size n-by-d
% nmix     - the number of mixture components to use
%
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
[model, loglikHist] = emAlgo(model, data, initFn, @estep, @mstep , ...
                            'verbose', true, EMargs{:});
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

%

