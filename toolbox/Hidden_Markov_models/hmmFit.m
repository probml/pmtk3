function [model, loglikHist] = hmmFit(data, nstates, type, varargin)
%% Fit an HMM model via EM
%
%% Inputs
% data         - a cell array of observations; each observation is 
%                d-by-seqLength, (where d is always 1 if type = 'discrete')
% 
% nstates      - the number of hidden states
%
% type         - as string, either 'gauss', or 'discrete' depending on the
%                desired emission distribution.
%% Optional named arguments
%
% pi0           - specify an initial value for the starting distribution
%                 instead of randomly initiializing. 
%
% trans0        - specify an initial value for the transition matrix 
%                 instead of randomly initializing, (rows must sum to one).
%
% emission0     - specify an initial value for the emission distribution
%                 instead of randomly initializing. If type is 'discrete',
%                 this is an nstates-by-nObsStates matrix, whos rows sum to
%                 one. If type is 'gauss', this is a cell array of gauss
%                 model structs, each with fields, 'mu', 'Sigma'. 
%
% piPrior       - pseudo counts for the starting distribution
%
% transPrior    - pseudo counts for the transition matrix, (either
%                nstates-by-nstates or 1-by-nstates in which case it is
%                automatically replicated. 
%
% emissionPrior - if type is 'discrete', these are pseduoCounts in an
%                 nstates-by-nObsStates matrix. Gauss prior not yet
%                 implemented. 
%
%% EM related inputs
% *** See emAlgo for additional EM related optional inputs ***
%
%% Outputs
%
% model         - a struct with fields, pi, A, emission, nstates, type
% loglikHist    - history of the log likelihood
%
%%
if ~iscell(data)
    if isvector(data) % scalar time series
        data = rowvec(data);
    end
    data = {data};
end
model.nstates = nstates;
model.type = type;
[   model.pi                    , ...
    model.A                     , ...
    model.emission              , ...
    model.piPrior               , ...
    model.transPrior            , ...
    model.emissionPrior         , ...
    EMargs                      ] ...
    = process_options(varargin  , ...
    'pi0'                       , []                        , ...
    'trans0'                    , []                        , ...
    'emission0'                 , []                        , ...
    'piPrior'                   , 2*ones(1, nstates)        , ...
    'transPrior'                , 2*ones(nstates, nstates)  , ...
    'emissionPrior'             ,[]);
model.piPrior = rowvec(model.piPrior);
if diff(size(model.transPrior))
    model.transPrior = repmat(rowvec(model.transPrior), nstates, 1);
end
%%
switch lower(type)
    case 'gauss'
        initFn = @(data)initGauss(data, model);
        estepFn = @(model, data)estep(model, data, @estepGaussEmission);
        [model, loglikHist] = emAlgo(data, initFn, estepFn, ...
                                    @mstepGauss, [], EMargs{:});
    case 'discrete'
        initFn = @(data)initDiscrete(data, model);
        estepFn = @(model, data)estep(model, data, @estepDiscreteEmission);
        [model, loglikHist] = emAlgo(data, initFn, estepFn,...
                                    @mstepDiscrete, [], EMargs{:});
    otherwise
        error('%s is not a valid output distribution type');
end
end

%% INIT
function model = initGauss(data, model)
%% Initialize Gaussian model
model.d = size(data{1}, 1);
nstates = model.nstates;
if isempty(model.pi)     
    model.pi = normalize(rand(1, nstates) +  model.piPrior -1); 
end
if isempty(model.A)
    model.A  = normalize(rand(nstates, nstates) + model.transPrior -1, 2); 
end
if isempty(model.emission)
    % Fit on random perturbations of the data, ignoring temporal structure.
    stackedData = cell2mat(data')';
    emission = cell(nstates, 1);
    for i=1:nstates
        emission{i} = gaussFit(stackedData + randn(size(stackedData)));
    end
    model.emission = emission;
end
end

function model = initDiscrete(data, model)
% Initialize the model
model.d = 1;
model.nObsStates = nunique(cell2mat(data')');
nstates = model.nstates;
nObsStates = model.nObsStates;
if isempty(model.emissionPrior)
    model.emissionPrior = 2*ones(nstates, model.nObsStates);
end
if isempty(model.pi)
    model.pi = normalize(rand(1, nstates) + model.piPrior);
end
if isempty(model.A)
    model.A = normalize(rand(nstates, nstates) + model.transPrior, 2);
end
if isempty(model.emission)
    model.emission = normalize(rand(nstates, nObsStates), 2);
end
end
%% ESTEP
function [ess, loglik] = estep(model, data, emissionEstep)
% Compute the expected sufficient statistics. 
stackedData   = cell2mat(data')';
seqidx        = cumsum([1, cellfun(@(seq)size(seq, 2), data')]);
seqidx        = seqidx(1:end-1);
nstacked      = size(stackedData, 1);
nstates       = model.nstates;
startCounts   = zeros(1, nstates);
transCounts   = zeros(nstates, nstates);
weights       = zeros(nstacked, nstates);
loglik = 0;
A = model.A;
nobs = numel(data);
for i=1:nobs
    obs = data{i}';
    [gamma, llobs, alpha, beta, B] = hmmInferState(model, obs);
    loglik = loglik + llobs;
    xi_summed = hmmComputeTwoSlice(alpha, beta, A, B);
    startCounts = startCounts + gamma(:, 1)';
    transCounts = transCounts + xi_summed;
    sz  = size(gamma, 2);
    idx = seqidx(i);
    ndx = idx:idx+sz-1;
    weights(ndx, :) = weights(ndx, :) + gamma';
end
logprior = log(A(:)+eps)'*(model.transPrior(:)-1) + ...
           log(model.pi(:)+eps)'*(model.piPrior(:)-1);
loglik = loglik + logprior;        
ess = structure(weights, startCounts, transCounts); 
[ess, logEmissionPrior] = emissionEstep(model, ess, stackedData); 
loglik = loglik + logEmissionPrior;
end

function [ess, logprior] = estepGaussEmission(model, ess, stackedData)
% Perform the Gaussian emission component of the estep.
logprior = 0; % Gauss emission prior not yet implemented
d = model.d;
nstates = model.nstates;
weights = ess.weights;
wsum = sum(weights, 1); 
xbar = bsxfun(@rdivide, stackedData'*weights, wsum); %d-by-nstates
XX   = zeros(d, d, nstates);
for j=1:nstates
    Xc = bsxfun(@minus, stackedData, xbar(:, j)');
    XX(:, :, j) = bsxfun(@times, Xc, weights(:, j))'*Xc/wsum(j);
end
ess.xbar = xbar;
ess.XX = XX;
ess.wsum = wsum; 
end

function [ess, logprior] = estepDiscreteEmission(model, ess, stackedData)
% Perform the discrete emission component of the estep.
weights = ess.weights; 
logprior = log(model.emission(:)+eps)'*(model.emissionPrior(:)-1);
ess.dataCounts = weights'*bsxfun(@eq, stackedData(:), sparse(1:model.nObsStates));
ess.wsum = sum(weights, 1)';
end
%% MSTEP
function model = mstepGauss(model, ess)
%% Maximize
model.pi = normalize(ess.startCounts + model.piPrior -1);
model.A  = normalize(ess.transCounts + model.transPrior -1, 2);
xbar = ess.xbar;
XX   = ess.XX;
nstates = model.nstates;
emission = cell(1, nstates);
for j=1:nstates
    emission{j}.mu = xbar(:, j);
    emission{j}.Sigma = XX(:, :, j);
end
model.emission = emission;
end

function model = mstepDiscrete(model, ess)
%% Maximize
model.pi = normalize(ess.startCounts + model.piPrior -1);
model.A  = normalize(ess.transCounts + model.transPrior -1, 2);
Epc = model.emissionPrior - 1;
denom = ess.wsum + sum(Epc, 2);
model.emission = bsxfun(@rdivide, ess.dataCounts + Epc, denom);
end