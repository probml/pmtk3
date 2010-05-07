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
    'piPrior'                   , ones(1, nstates)        , ...
    'transPrior'                , ones(nstates, nstates)  , ...
    'emissionPrior'             ,[]);
model.piPrior = rowvec(model.piPrior);
if diff(size(model.transPrior))
    model.transPrior = repmat(rowvec(model.transPrior), nstates, 1);
end
%%
switch lower(type)
    case 'gauss'
        initFn = @(data)initGauss(data, model);
        [model, loglikHist] = emAlgo(data, initFn, @estepGauss, ...
                                    @mstepGauss, [], EMargs{:});
    case 'discrete'
        initFn = @(data)initDiscrete(data, model);
        [model, loglikHist] = emAlgo(data, initFn, @estepDiscrete,...
                                    @mstepDiscrete, [], EMargs{:});
    otherwise
        error('%s is not a valid output distribution type');
end
end

%% Gauss
function model = initGauss(data, model)
%% Initialize Gaussian model
model.d = size(data{1}, 1);
nstates = model.nstates;
if isempty(pi)     
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

function [ess, loglik] = estepGauss(model, data)
%% Compute expected sufficient statistics
stackedData   = cell2mat(data')';
seqidx        = cumsum([1, cellfun(@(seq)size(seq, 2), data')]);
seqidx        = seqidx(1:end-1);
[nstacked, d] = size(stackedData);
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
wsum = sum(weights, 1);
xbar = bsxfun(@rdivide, stackedData'*weights, wsum); %d-by-nstates
XX   = zeros(d, d, nstates);
for j=1:nstates
    Xc = bsxfun(@minus, stackedData, xbar(:, j)');
    XX(:, :, j) = bsxfun(@times, Xc, weights(:, j))'*Xc/wsum(j);
end
ess.startCounts = startCounts;
ess.transCounts = transCounts;
ess.xbar = xbar;
ess.XX = XX;
end

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

%% Discrete
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

function [ess, loglik] = estepDiscrete(model, data)
% Compute expected sufficient statistics
nobs         = numel(data);
nObsStates   = model.nObsStates;
stackedData  = cell2mat(data')';
seqidx       = cumsum([1, cellfun(@(seq)size(seq, 2), data')]);
seqidx       = seqidx(1:end-1);
nStackedData = length(stackedData);
nstates      = model.nstates;
A            = model.A;
startCounts  = zeros(1, nstates);
transCounts  = zeros(nstates, nstates);
weights      = zeros(nStackedData, nstates);
loglik = 0;
for i=1:nobs
    obs = colvec(data{i});
    [gamma, obsLL, alpha, beta, B] = hmmInferState(model, obs);
    loglik = loglik + obsLL;
    startCounts = startCounts + gamma(:, 1)';
    transCounts = transCounts + hmmComputeTwoSlice(alpha, beta, A, B);
    sz  = size(gamma, 2);
    idx = seqidx(i);
    ndx = idx:idx+sz-1;
    weights(ndx, :) = weights(ndx, :) + gamma';
end
logprior = log(A(:)+eps)'*(model.transPrior(:)-1)  + ...
        log(model.pi(:)+eps)'*(model.piPrior(:)-1) +...
        log(model.emission(:)+eps)'*(model.emissionPrior(:)-1);
loglik = loglik + logprior;     
dataCounts = weights'*bsxfun(@eq, stackedData(:), sparse(1:nObsStates));
wsum = sum(weights, 1)';
ess = structure(startCounts, transCounts, dataCounts, wsum);
end

function model = mstepDiscrete(model, ess)
% Maximization step
model.pi = normalize(ess.startCounts + model.piPrior -1);
model.A  = normalize(ess.transCounts + model.transPrior -1, 2);

Epc = model.emissionPrior - 1;
denom = ess.wsum + sum(Epc, 2);
model.E = bsxfun(@rdivide, ess.dataCounts + Epc, denom);

end