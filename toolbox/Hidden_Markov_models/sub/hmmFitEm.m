function [model, loglikHist] = hmmFitEm(data, nstates, type, varargin)
%% Fit an HMM model via EM
% Interface is identical to hmmFit
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
    'emissionPrior'             , []);
model.piPrior = rowvec(model.piPrior);
if diff(size(model.transPrior))
    model.transPrior = repmat(rowvec(model.transPrior), nstates, 1);
end
%%
switch lower(type)
    case 'gauss'
        initFn          = @initGauss;
        estepEmissionFn = @estepGaussEmission;
        mstepFn         = @mstepGauss;
    case 'discrete'
        initFn          = @initDiscrete;
        estepEmissionFn = @estepDiscreteEmission;
        mstepFn         = @mstepDiscrete;
    otherwise
        error('%s is not a valid output distribution type');
end
estepFn = @(model, data)estep(model, data, estepEmissionFn);
[model, loglikHist] = emAlgo(model, data, initFn, estepFn, mstepFn, EMargs{:});
end

%% INIT
function model = initGauss(model, data, restartNum)
%% Initialize the model given a Gaussian emission distribution
d = size(data{1}, 1);
model.d = d;
if isempty(model.emissionPrior)
    model.emissionPrior.mu    = zeros(1, d);
    model.emissionPrior.Sigma = 0.1*eye(d);
    model.emissionPrior.k     = 0.01;
    model.emissionPrior.dof   = d + 1;
end
if isempty(model.emission) || isempty(model.pi) || isempty(model.A)
    if restartNum == 1
        model = initWithMixModel(model, data, @mixGaussFit, @mixGaussInfer);
        Sigma = bsxfun(@plus, model.emission.Sigma, eye(model.d));
        model.emission.Sigma = Sigma;  % regularize MLE
    else 
        nstates     = model.nstates;
        stackedData = cell2mat(data')';
        mu          = zeros(d, nstates);
        Sigma       = zeros(d, d, nstates);
        for k = 1:nstates
            XX             = stackedData + randn(size(stackedData));
            mu(:, k)       = colvec(mean(XX));
            Sigma(:, :, k) = cov(XX);
        end
        model.emission = condGaussCpdCreate(mu, Sigma);
        model = rndInitPiA(model); 
    end
end
end

function model = initDiscrete(model, data, restartNum) 
%% Initialize the model given a discrete emission distribution
model.d          = 1;
nstates          = model.nstates;
nObsStates       = nunique(cell2mat(data')');
model.nObsStates = nObsStates; 
if isempty(model.emissionPrior)
    model.emissionPrior = 2*ones(nstates, nObsStates);
end
if isempty(model.emission) || isempty(model.pi) || isempty(model.A)
    if restartNum == 1
        model = initWithMixModel(model, data, @mixDiscreteFit, @mixDiscreteInfer); 
    else
        T = normalize(rand(nstates, nObsStates), 2);
        model.emission = tabularCpdCreate(T);
        model = rndInitPiA(model); 
    end
end
end

%% ESTEP
function [ess, loglik] = estep(model, data, emissionEstep)
%% Compute the expected sufficient statistics
stackedData = cell2mat(data')';
seqidx      = cumsum([1, cellfun(@(seq)size(seq, 2), data')]);
seqidx      = seqidx(1:end-1);
nstacked    = size(stackedData, 1);
nstates     = model.nstates;
startCounts = zeros(1, nstates);
transCounts = zeros(nstates, nstates);
weights     = zeros(nstacked, nstates);
loglik      = 0;
A           = model.A;
nobs        = numel(data);
for i = 1:nobs
    obs                            = data{i};
    [gamma, llobs, alpha, beta, B] = hmmInferNodes(model, obs);
    %fprintf('%g\n',llobs); 
    loglik                         = loglik + llobs;
    xi_summed                      = hmmComputeTwoSlice(alpha, beta, A, B);
    startCounts                    = startCounts + gamma(:, 1)';
    transCounts                    = transCounts + xi_summed;
    sz                             = size(gamma, 2);
    idx                            = seqidx(i);
    ndx                            = idx:idx+sz-1;
    weights(ndx, :)                = weights(ndx, :) + gamma';
end
logprior                = log(A(:)+eps)'*(model.transPrior(:)-1) + ...
                          log(model.pi(:)+eps)'*(model.piPrior(:)-1);
loglik                  = loglik + logprior;
ess                     = structure(weights, startCounts, transCounts);
[ess, logEmissionPrior] = emissionEstep(model, ess, stackedData);
loglik                  = loglik + logEmissionPrior;
end

function [ess, logprior] = estepGaussEmission(model, ess, stackedData)
%% Perform the Gaussian emission component of the estep.
emission       = model.emission; 
emissionEss    = condGaussCpdComputeEss(emission, stackedData, ess.weights);
ess.xbar       = emissionEss.xbar;
ess.XX         = emissionEss.XX;
ess.wsum       = emissionEss.wsum;
emission.prior = model.emissionPrior; 
logprior       = emission.logPriorFn(emission);
end

function [ess, logprior] = estepDiscreteEmission(model, ess, stackedData)
%% Perform the discrete emission component of the estep.
%
% Since we've computed the weights already, we operate with all of
% observation sequences in one long vector: stackedData. The actual
% sequence lengths, (which can vary) only affect the computation of pi, A,
% and weights, not the weighted emission counts: dataCounts.
%
% ess.weights is n-by-nstates, where n is the length of stackedData. S is a
% n-by-nObsStates sparse binary matrix s.t. S(i, j) = 1 iff
% stackedData(i) == j and acts as an indicator function. The weights'*S
% matrix multiply sums the entries in weights according to S, resulting in
% an nstates-by-nObsStates dataCounts matrix: dataCounts(h, o) is equal to
% the weighted (i.e. expected) count of the joint occurance of hidden
% state h and observed state o, which will be normalized so that rows sum
% to one in the maximization step.
logprior       = log(model.emission.T(:)+eps)'*(model.emissionPrior(:)-1);
weights        = ess.weights;
S              = bsxfun(@eq, stackedData(:), sparse(1:model.nObsStates));
ess.dataCounts = weights'*S; % dataCounts is nstates-by-nObsStates
ess.wsum       = sum(weights, 1)';
end

%% MSTEP

function model = mstepGauss(model, ess)
%% Maximize
model.pi       = normalize(ess.startCounts + model.piPrior -1);
model.A        = normalize(ess.transCounts + model.transPrior -1, 2);
emission       = model.emission;
emission.prior = model.emissionPrior; 
model.emission = condGaussCpdFitEss(emission, ess); 
end

function model = mstepDiscrete(model, ess)
%% Maximize
model.pi       = normalize(ess.startCounts + model.piPrior -1);
model.A        = normalize(ess.transCounts + model.transPrior -1, 2);
Epc            = model.emissionPrior - 1;
denom          = ess.wsum + sum(Epc, 2);
model.emission = tabularCpdCreate(bsxfun(@rdivide, ess.dataCounts + Epc, denom));
end

%% Init Helpers

function model = rndInitPiA(model)
%% Randomly initialize pi and A
nstates  = model.nstates; 
model.pi = normalize(rand(1, nstates) + model.piPrior -1);
model.A  = normalize(rand(nstates) + model.transPrior -1, 2);
end

function model = initWithMixModel(model, data, fitFn, inferFn)
%% Initialze using a mixture model, ignoring temporal structure
stackedData = cell2mat(data')';
nstates     = model.nstates;
mixModel    = fitFn(stackedData, nstates, 'verbose', false);
if isempty(model.emission)
    model.emission = mixModel2Cpd(mixModel);
end
if isempty(model.A) || isempty(model.pi)
    z = colvec(inferFn(mixModel, stackedData));
    if isempty(model.A)
        A       = accumarray([z(1:end-1), z(2:end)], 1); % count transitions
        model.A = normalize(A + ones(size(A)), 2);       % regularize
    end
    if isempty(model.pi)
        % seqidx(1:end-1) are the start indices of the sequences
        seqidx   = cumsum([1, cellfun(@(seq)size(seq, 2), data')]);
        pi       = histc(z(seqidx(1:end-1)), 1:nstates);
        model.pi = normalize(pi + ones(size(pi))); % regularize
    end
end
end