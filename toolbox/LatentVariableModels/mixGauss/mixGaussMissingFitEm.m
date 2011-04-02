function [model, loglikHist] = mixGaussMissingFitEm(data, K, varargin)
% Fit a mixture of Gaussians where the data may have NaN entries
% Set doMAP = 1 to do MAP estimation (default)
% Set diagCov = 1 to use and diagonal covariances (does not currently save
% space)
%PMTKauthor Kevin Murphy
%PMTKmodified Hannes Bretschneider
%%

% This file is from pmtk3.googlecode.com

[model.cpd.mu, model.cpd.Sigma, model.mixWeight, model.doMap, model.diagCov, EMargs] = ...
    process_options(varargin , ...
    'mu0'         , [] , ...
    'Sigma0'      , [] , ...
    'mixweight0'  , [] , ...
    'doMap'       , true , ...
    'diagCov'     , 0);
%%
model.nmix = K;
[model, loglikHist] = emAlgo(model, data, @init, @estep, @mstep, EMargs{:});
end

function model = init(model, data, restartNum) %#ok
%% Initialize

d = size(data, 2); 
model.d = d; 
ismissing = sparse(isnan(data));
K = model.nmix;
if model.doMap
    model.prior.mu    = zeros(1, d);
    model.prior.k     = 0;
    model.prior.dof   = d+2;
    model.prior.Sigma = (1./K.^(1/d)).*var(data(~ismissing))*eye(d);
else
    model.prior = [];
end
if isempty(model.cpd) || isempty(model.mixWeight)
    dataFilled = data;
    dataFilled(ismissing) = randn(nnz(ismissing), 1);
    %initModel = mixModelFit(dataFilled, K, 'gauss', 'verbose', false);
    initModel = mixGaussFit(dataFilled, K, 'verbose', false);
    if isempty(model.cpd.mu)
        model.cpd.mu = initModel.cpd.mu;
    end
    if isempty(model.cpd.Sigma)
        model.cpd.Sigma = initModel.cpd.Sigma + repmat(eye(model.d), [1 1 K]);
    end
    if isempty(model.mixWeight)
        model.mixWeight = normalize(initModel.mixWeight + 0.1);
    end
end
model.ismissing = ismissing;
end

function [ess, loglik] = estep(model, data)
%% Compute the expected sufficient statistics
ismissing = model.ismissing;
K = model.nmix;
[n, d] = size(data); 

mu     = model.cpd.mu;
Sigma  = model.cpd.Sigma;
%[z, rik, ll] = mixGaussInfer(model, data);
[rik, ll] = mixGaussInferLatent(model, data);
loglik = sum(ll);
if ~isempty(model.prior)
    % add log prior
    prior  = model.prior;
    kappa0 = prior.k;
    m0     = prior.mu(:);
    nu0    = prior.dof;
    S0     = prior.Sigma;
   
    logprior = 0;
    for c=1:K
        %Sinv = inv(Sigma(:, :, c));
        % note logdet(Sinv) == -logdet(S)
        S = Sigma(:, :, c); 
        logprior = logprior + ...
            -logdet(S)*(nu0 + d + 2)/2 - 0.5*trace(S\S0) ...
            -kappa0/2*(mu(:, c)-m0)'*(S\(mu(:, c)-m0)); 
    end
    loglik = loglik + logprior;
end

% E step for missing values of X
% We accumulated the ESS in place to save memory
muik = zeros(d, K); % muik(:,k) = sum_i r(i,k) E[xi | zi=k, xiv]
Vik = zeros(d, d, K); % Vik(:,:,k) = sum_i r(i,k) E[xi xi' | zi=k, xiv]
expVals = zeros(d, 1);
expProd = zeros(d, d); % temporary storage
for k=1:K
    muk = mu(:,k);
    Sigmak=Sigma(:,:,k);
    for i=1:n
        u = ismissing(i,:); % unobserved entries
        o = ~u; % observed entries
        Sigmai = Sigmak(u,u) - Sigmak(u,o) /Sigmak(o,o)* Sigmak(o,u);
        expVals(u) = muk(u) + Sigmak(u,o)/Sigmak(o,o)*(data(i, o)'-muk(o));
        expVals(o) = data(i, o)';
        expProd(u,u) = (expVals(u) * expVals(u)' + Sigmai);
        expProd(o,o) = expVals(o) * expVals(o)';
        expProd(o,u) = expVals(o) * expVals(u)';
        expProd(u,o) = expVals(u) * expVals(o)';
        muik(:,k) = muik(:,k) + rik(i,k)*expVals;
        Vik(:,:,k) = Vik(:,:,k) + rik(i,k)*expProd;
    end
end
rk = sum(rik,1);
ess = structure(Vik, muik, rk);
end

function model = mstep(model, ess)
%% Maximize
K     = model.nmix; 
d     = model.d; 
Vik   = ess.Vik;
muik  = ess.muik;
rk    = ess.rk; 
mu    = model.cpd.mu;
Sigma = model.cpd.Sigma; 
model.mixWeight = normalize(rk);
diagCov = model.diagCov; 
if ~isempty(model.prior)
    kappa0 = model.prior.k; 
    m0     = model.prior.mu(:);
    nu0    = model.prior.dof; 
    S0     = model.prior.Sigma;
    for c=1:K
        mu(:,c) = (muik(:,c)+kappa0*m0)./(rk(c)+kappa0);
        a = (kappa0*rk(c))./(kappa0 + rk(c));
        b = nu0 + rk(c) + d + 2;
        Sprior = (muik(:,c)-m0)*(muik(:,c)-m0)';
        Sk = (Vik(:,:,c) - rk(c)*mu(:,c)*mu(:,c)');
        if diagCov
            Sigma(:,:,c) = diag(diag((S0 + Sk + a*Sprior)./b));
        else
            Sigma(:,:,c) = (S0 + Sk + a*Sprior)./b;
        end
    end
else
    for c=1:K
        mu(:,c) = muik(:,c)/rk(c);
        if diagCov
            Sigma(:,:,c) = diag(diag((Vik(:,:,c) -...
                rk(c)*mu(:,c)*mu(:,c)')/rk(c)));
        else
            Sigma(:,:,c) = (Vik(:,:,c) - rk(c)*mu(:,c)*mu(:,c)')/rk(c);
        end
    end
end
model.cpd.mu = mu; 
model.cpd.Sigma = Sigma; 
end

