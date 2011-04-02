function [model, loglikHist] = mixDiscreteFit(data, nmix, varargin)
%% Fit a mixture of product of multinoullis via MLE/MAP (using EM)
%
% By default we lightly regularize the parameters, so we are doing map
% estimation. To turn this off, set 'prior' and 'mixPrior to 'none'. See
% Inputs below.
%
%% Inputs
%
% data     - data(n, :) is the ith case, i.e. data is of size N*D
%  We current require that data(n, d) in {1...C} where
%  C is the same for all dimensions
% nmix     - the number of mixture components to use
% alpha     - value of Dirichlet prior on observations, default 1.1 (1=MLE)
% EMargs - cell arrya, see emAlgo


% This file is from pmtk3.googlecode.com

[initParams, mixPrior, alpha,  verbose, EMargs] = ...
    process_options(varargin, ...
    'initParams'        , [], ...
    'mixPrior', [], ...
    'alpha', 1.1, ...        
    'verbose', true);
     
[n, d]      = size(data);
model.type  = 'mixDiscrete';
model.nmix  = nmix;
model.d     = d;
model       = setMixPrior(model, mixPrior );
prior.alpha = alpha;
initFn = @(m, X, r)initDiscrete(m, X, r, initParams, prior); 
[model, loglikHist] = emAlgo(model, data, initFn, @estep, @mstep , ...
                            'verbose', verbose, EMargs{:});
end


function model = initDiscrete(model, X, restartNum, initParams, prior)
%% Initialize
nObsStates = max(nunique(X(:)));
if restartNum == 1 && ~isempty(initParams)
    T = initParams.T;
    model.mixWeight = initParams.mixWeight;
else
    % randomly partition data, fit each partition separately, add noise.
    nmix    = model.nmix;
    d       = size(X, 2);
    T       = zeros(nmix, nObsStates, d);
    Xsplit  = randsplit(X, nmix);
    for k=1:nmix
        m = discreteFit(Xsplit{k}, 1, nObsStates);
        T(k, :, :) = m.T;
    end
    T               = normalize(T + 0.2*rand(size(T)), 2); % add noise
    model.mixWeight = normalize(10*rand(1, nmix) + ones(1, nmix));
end
model.cpd = condDiscreteProdCpdCreate(T, 'prior', prior); 
end


function [ess, loglik] = estep(model, data)
%% Compute the expected sufficient statistics
[weights, ll] = mixDiscreteInferLatent(model, data); 
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

