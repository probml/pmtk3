function [model, loglikHist] = mixGaussFitEm(data, K, varargin)
% EM for fitting mixture of K gaussians
% data(i,:) is i'th case
% To perform MAP estimation using a vague conjugate prior, use
%  model = mixGaussFitEm(data, K, 'doMAP', 1) [default]
% See emAlgo() for other optional arguments.
%
% Return arguments:
% model is a structure containing these fields:
%   mu(:,k) is k'th centroid
%   Sigma(:,:,k)
%   mixweight(k)
%%

[   maxIter    , ...
    convTol    , ...
    plotfn     , ...
    verbose    , ...
    mu         , ...
    Sigma      , ...
    mixweight  , ...
    doMAP      , ...
    overRelaxFactor] = process_options(varargin, ...
    'maxIter'  , 100   , ...
    'convTol'  , 1e-4  , ...
    'plotfn'   , []    , ...
    'verbose'  , false , ...
    'mu'       , []    , ...
    'Sigma'    , []    , ...
    'mixweight', []    , ...
    'doMAP'    , 1     , ...
    'overRelaxFactor', []);

[N,D] = size(data);

%% Create data-dependent prior
if doMAP
    % set hyper-parameters
    prior.mu = zeros(D,1);
    prior.k = 0.01;
    prior.dof = D+2;
    prior.Sigma = (1/K^(1/D))*var(data(:))*eye(D);
else
    prior = [];
end
%% Fit
model = structure(K, mu, Sigma, mixweight, prior);
if isempty(overRelaxFactor)
    mstepORfn = [];
else
    mstepORfn = @mstepOR;
end
[model, loglikHist] = emAlgo(model, data, @init, @estep,  @mstep, ...
    'mstepOR'         , mstepORfn , ...
    'maxIter'         , maxIter   , ...
    'convTol'         , convTol   , ...
    'verbose'         , verbose   , ...
    'plotfn'          , plotfn    , ...
    'overRelaxFactor' , overRelaxFactor);
model.K = K;
end

function model = init(model, data, restartNum) %#ok
% Initialize params
if isempty(model.mu)
    K = model.K;
    prior = model.prior;
    [mu, Sigma, mixweight] = kmeansInitMixGauss(data, K);
    model = structure(K, mu, Sigma, mixweight, prior);
end
end

function model = mstep(model, ess)
[D, D2, K] = size(ess.Sk);
mixweight = normalize(ess.w);
% Set any zero weights to one before dividing
% This is valid because w(c)=0 => WY(:,c)=0, and 0/0=0
w = ess.w + (ess.w==0);
Sigma = zeros(D,D,K);
mu = zeros(D,K);
prior = model.prior;
if ~isempty(prior)
    kappa0 = prior.k; m0 = prior.mu;
    nu0 = prior.dof; S0 = prior.Sigma;
    for c=1:K
        mu(:,c) = (w(c)*ess.ybark(:,c)+kappa0*m0)./(w(c)+kappa0);
        a = (kappa0*w(c))./(kappa0 + w(c));
        b = nu0 + w(c) + D + 2;
        Sprior = (ess.ybark(:,c)-m0)*(ess.ybark(:,c)-m0)';
        Sigma(:,:,c) = (S0 + ess.Sk(:,:,c) + a*Sprior)./b;
    end
else
    for c=1:K
        mu(:,c) = ess.ybark(:,c);
        Sigma(:,:,c) = ess.Sk(:,:,c)/w(c);
    end
end
model = structure(mu, Sigma, mixweight, prior);
end


function [model, valid] = mstepOR(model, modelBO, eta)
% For over-relaxed EM
[D, D2, K] = size(modelBO.Sigma);
% Since weights are constrained to sum to one,
% we do update in softmax parameterization
mixweight = model.mixweight.*(modelBO.mixweight./ model.mixweight).^eta;
mixweight = normalize(mixweight);
Sigma = zeros(D,D,K);
mu = zeros(D,K);
valid = true;
for c=1:K
    % Regular update
    mu(:,c) = model.mu(:,c) + eta*(modelBO.mu(:,c) - model.mu(:,c));
    %Since Sigma is constrained to positive definite matrices,
    %the updation of Sigma is done in the Log-Euclidean space.
    %(ref: "Fast and Simple Calculus on Tensors in the Log-Euclidean
    %Framework", Vincent Arsigny, Pierre Fillard, Xavier Pennec,
    %and Nicholas Ayache)
    try
        matLogSigma = logm(model.Sigma(:,:,c));
        matLogSigma_BO = logm(modelBO.Sigma(:,:,c));
        matLogSigma = matLogSigma + eta*(matLogSigma_BO - matLogSigma);
        Sigma(:,:,c) = expm(matLogSigma);
    catch %#ok
        valid  = false; return;
    end
    if ~isposdef(Sigma(:,:,c))
        valid = false; return;
    end
end
prior = model.prior;
model = structure(mu, Sigma, mixweight, prior);
end



function [ess, loglik] = estep(model, data)
[N,D] = size(data);
K = numel(model.mixweight);
Y = data'; % Y(:,i) is i'th case
[z, post, ll] = mixGaussInfer(model, data); %#ok
% post(i,c) = responsibility for cluster c, point i

% Evaluate objective funciton
loglik = sum(ll);
prior = model.prior;
if ~isempty(prior)
    % add log prior
    logprior = zeros(1,K);
    mu = model.mu;
    Sigma = model.Sigma;
    for c=1:K
        logprior(c) = gaussInvWishartLogprob(prior, mu(:, c), Sigma(:, :, c));
    end
    loglik = loglik + sum(logprior);
end

% compute expected sufficient statistics
w = sum(post,1);  % w(c) = sum_i post(c,i)
Sk = zeros(D,D,K);
ybark = zeros(D,K);
for c=1:K
    weights = repmat(post(:,c), 1, D)'; % weights(:,i) = post(i,c)
    Yk = Y .* weights; % Yk(:,i) = post(c,i) * Y(:,i)
    ybark(:,c) = sum(Yk/w(c),2);
    Ykmean = Y - repmat(ybark(:,c),1,N);
    Sk(:,:,c) = weights.*Ykmean*Ykmean';
end

ess = structure(Sk, ybark, w, post);
end

