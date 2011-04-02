function [model, loglikHist] = hmmFitEm(data, nstates, type, varargin)
%% Fit an HMM model via EM
% Interface is identical to hmmFit
%%

% This file is from pmtk3.googlecode.com

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
    emissionPrior               , ...
    model.nmix                  , ...
    EMargs                      ] ...
    = process_options(varargin  , ...
    'pi0'                       , []                        , ...
    'trans0'                    , []                        , ...
    'emission0'                 , []                        , ...
    'piPrior'                   , 1*ones(1, nstates)        , ...
    'transPrior'                , 1*ones(nstates, nstates)  , ...
    'emissionPrior'             , []                        , ...
    'nmix'                      , []);

model.piPrior = rowvec(model.piPrior);
if diff(size(model.transPrior))
    model.transPrior = repmat(rowvec(model.transPrior), nstates, 1);
end
%%
switch lower(type)
    case 'gauss'        , initFn = @initGauss;
    case 'mixgausstied' , initFn = @initMixGaussTied;
    case 'discrete'     , initFn = @initDiscrete;
    case 'student'      , initFn = @initStudent;
    otherwise           , error('%s is not a valid output distribution type');
end
initFn = @(m, X, r)initFn(m, X, r, emissionPrior);
[model, loglikHist] = emAlgo(model, data, initFn, @estep, @mstep, EMargs{:});
end

function [ess, loglik] = estep(model, data)
%% Compute the expected sufficient statistics
stackedData   = cell2mat(data')';
seqidx        = cumsum([1, cellfun(@(seq)size(seq, 2), data')]); % keep track of where sequences start
nstacked      = size(stackedData, 1);
nstates       = model.nstates;
startCounts   = zeros(1, nstates);
transCounts   = zeros(nstates, nstates);
weights       = zeros(nstacked, nstates);
loglik        = 0;
A             = model.A;
pi            = model.pi;
nobs          = numel(data);
logB          = mkSoftEvidence(model.emission, stackedData'); 
[logB, scale] = normalizeLogspace(logB'); 
B             = exp(logB'); 
for i=1:nobs
    ndx                        = seqidx(i):seqidx(i+1)-1;
    Bi                         = B(:, ndx); 
    [gamma, alpha, beta, logp] = hmmFwdBack(pi, A, Bi);
    loglik                     = loglik + logp; 
    xiSummed                   = hmmComputeTwoSliceSum(alpha, beta, A, Bi);
    startCounts                = startCounts + gamma(:, 1)';
    transCounts                = transCounts + xiSummed;
    weights(ndx, :)            = weights(ndx, :) + gamma';
end
loglik   = loglik + sum(scale); 
%logprior = log(A(:)+eps)'*(model.transPrior(:)-1) + log(pi(:)+eps)'*(model.piPrior(:)-1);
logprior = log(A(:)+eps)'*(model.transPrior(:)) + log(pi(:)+eps)'*(model.piPrior(:));
loglik   = loglik + logprior;
%% emission component (generic)
emission        = model.emission; 
ess             = emission.essFn(emission, stackedData, weights, B);
ess.startCounts = startCounts; 
ess.transCounts = transCounts; 
loglik          = loglik + emission.logPriorFn(emission);
end

function model = mstep(model, ess)
%% Generic mstep function
%model.pi       = normalize(ess.startCounts + model.piPrior -1);
%model.A        = normalize(ess.transCounts + model.transPrior -1, 2);
model.pi       = normalize(ess.startCounts + model.piPrior);
model.A        = normalize(ess.transCounts + model.transPrior, 2);
emission       = model.emission;
model.emission = emission.fitFnEss(emission, ess); 
end

%% INIT
function model = initStudent(model, data, restartNum, emissionPrior)
%% Initialize the model given a student emission distribution 
d = size(data{1}, 1);
if ~isempty(model.emission) && ~isempty(model.emission.dof)
    dof = model.emission.dof; 
    fixDof = true;
else
    dof = 10*ones(1, model.nstates); 
    fixDof = false;
end
model.d = d;
if isempty(model.emission) || isempty(model.pi) || isempty(model.A)
    if restartNum == 1
        model = initWithMixModel(model, data);
        Sigma = bsxfun(@plus, model.emission.Sigma, eye(model.d));
        mu    = model.emission.mu; 
        if ~fixDof
           dof = model.emission.dof; 
        end
        % we do not estimate the dof in the hmm model; we use the either
        % a user set value, or a value(s) estimated once ignoring temporal
        % structure. 
        model.emission = condStudentCpdCreate(mu, Sigma, dof, 'prior', emissionPrior, 'estimateDof', false); 
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
        model.emission = condStudentCpdCreate(mu, Sigma, dof, 'prior', emissionPrior, 'estimateDof', false);
        model = rndInitPiA(model); 
    end
end
if ~isempty(emissionPrior)
    model.emission.prior = emissionPrior; 
end
end

function model = initGauss(model, data, restartNum, emissionPrior)
%% Initialize the model given a Gaussian emission distribution
d = size(data{1}, 1);
model.d = d;
if isempty(model.emission) || isempty(model.pi) || isempty(model.A)
    if restartNum == 1
        model = initWithMixModel(model, data);
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
if ~isempty(emissionPrior)
    model.emission.prior = emissionPrior; 
end
end

function model = initMixGaussTied(model, data, restartNum, emissionPrior)
%% Initialize the model given a tied mixGauss emission distribution
assert(~isempty(model.nmix)); % you must specify the number of mixture components
d = size(data{1}, 1);
model.d = d;
nstates     = model.nstates;
nmix        = model.nmix;
stackedData = cell2mat(data')';
if isempty(model.emission) || isempty(model.pi) || isempty(model.A)
    if restartNum == 1
        stackedData = cell2mat(data')';
        nmix = model.nmix;
        %mixModel = mixModelFit(stackedData, nmix, 'gauss', 'verbose', false, 'maxIter', 10);
        mixModel = mixGaussFit(stackedData, nmix, 'verbose', false, 'maxIter', 10);
        if isempty(model.emission)
            mu = mixModel.cpd.mu;
            Sigma = bsxfun(@plus, eye(d), mixModel.cpd.Sigma); 
            M = repmat(mixModel.mixWeight, nstates, 1); 
            M = normalize(M + rand(size(M)), 1); %break symmetry
            model.emission = condMixGaussTiedCpdCreate(mu, Sigma, M); 
        end
        model = rndInitPiA(model);
    else        
        mu          = zeros(d, nmix);
        Sigma       = zeros(d, d, nmix);
        for k = 1:nmix
            XX             = stackedData + randn(size(stackedData));
            mu(:, k)       = colvec(mean(XX));
            Sigma(:, :, k) = cov(XX);
        end
        M = normalize(rand(nstates, nmix), 1);
        model.emission = condMixGaussTiedCpdCreate(mu, Sigma, M);
        model = rndInitPiA(model);
    end
end
if ~isempty(emissionPrior)
    model.emission.prior = emissionPrior; 
end
end

function model = initDiscrete(model, data, restartNum, emissionPrior) 
%% Initialize the model given a discrete emission distribution
d                = size(data{1}, 1);
model.d          = d;
nstates          = model.nstates;
nObsStates       = max(cell2mat(data'));
model.nObsStates = nObsStates; 
if isempty(model.emission) || isempty(model.pi) || isempty(model.A)
    if restartNum == 1
        model = initWithMixModel(model, data); 
    else
        T = normalize(rand(nstates, nObsStates, d), 2);
        model.emission = condDiscreteProdCpdCreate(T);
        model = rndInitPiA(model); 
    end
end
if ~isempty(emissionPrior)
    model.emission.prior = emissionPrior; 
end
end

%% Init Helpers
function model = rndInitPiA(model)
%% Randomly initialize pi and A
nstates  = model.nstates; 
model.pi = normalize(rand(1, nstates) + model.piPrior -1);
model.A  = normalize(rand(nstates) + model.transPrior -1, 2);
end

function [model, mixModel] = initWithMixModel(model, data)
%% Initialze using a mixture model, ignoring temporal structure
stackedData = cell2mat(data')';
nstates     = model.nstates;
%mixModel    = mixModelFit(stackedData, nstates, model.type, 'verbose', false, 'maxIter', 10);
switch lower(model.type)
  case 'gauss'
    mixModel    = mixGaussFit(stackedData, nstates,  'verbose', false, 'maxIter', 10);
  case 'discrete'
    mixModel    = mixDiscreteFit(stackedData, nstates,  'verbose', false, 'maxIter', 10);
  case 'student'
    mixModel    = mixStudentFit(stackedData, nstates,  'verbose', false, 'maxIter', 10);
  otherwise
    error(['unrecognized observation distribution ' model.type])
end

if isempty(model.emission)
   model.emission = mixModel.cpd; 
end
if isempty(model.A) || isempty(model.pi)
    %z = colvec(mixModelMapLatent(mixModel, stackedData));
    %pz = mixModelInferLatent(mixModel, stackedData);
    switch lower(model.type)
      case 'gauss'
        pz = mixGaussInferLatent(mixModel, stackedData);
      case 'discrete'
        pz = mixDiscreteInferLatent(mixModel, stackedData);
      case 'student'
        pz = mixStudentInferLatent(mixModel, stackedData);
      otherwise
        error(['unrecognized observation distribution ' model.type])
    end
    [~,z] = max(pz,[],2);
    z = colvec(z);
    if isempty(model.A)
        A       = accumarray([z(1:end-1), z(2:end)], 1, [nstates, nstates]); % count transitions
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
