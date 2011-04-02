function [model, loglikHist] = mixStudentFit(data, nmix, varargin)
%% Fit a mixture of multivariate Student Ts via MLE/MAP (using EM)
%
% data     - data(i, :) is the ith case, i.e. data is of size n-by-d
% nmix     - the number of mixture components to use


% This file is from pmtk3.googlecode.com



[mixPrior, initParams, prior, EMargs] = ...
    process_options(varargin, ...
    'mixPrior', [], ...
    'initParams'        , [], ...
    'prior'             , []);
[n, d]      = size(data);
model.type  = 'mixStudent';
model.nmix  = nmix;
model.d     = d;
model       = setMixPrior(model, mixPrior);
initFn = @(m, X, r)initStudent(m, X, r, initParams, prior); 
[model, loglikHist] = emAlgo(model, data, initFn, @estep, @mstep, ... 
                            'verbose', true, ...
                            EMargs{:});
end


function model = initStudent(model, X, restartNum, initParams, prior)
%% Initialize
% Initialize of the back of initGauss, and then just add dof
model = initGauss(model, X, restartNum, initParams, prior); 
if ~isempty(initParams)
    dof = initParam.dof;
else
    dof = 10*ones(1, model.nmix); 
end
initCpd   = model.cpd; 
model.cpd = condStudentCpdCreate(initCpd.mu, initCpd.Sigma, dof, 'prior', prior); 
end

function [ess, loglik] = estep(model, data)
%% Compute the expected sufficient statistics
[weights, ll] = mixStudentInferLatent(model, data); 
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