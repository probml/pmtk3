function [model, loglikHist] = mixGaussDiscreteMissingFitEm(data, K, types, varargin)
%% Class-conditional is product of Gaussians and multinoullis
% p(x|z=k) = prod_{j in C} N(x_j|mu_{jk},sigma_{jk}) * ...
%            prod_{j in D} discrete(x_j | beta_{jk})

% This file is from pmtk3.googlecode.com


% Parameter of model are:
% beta(c,j,k) = p(xj=c|z=k)
% muk(j,k), sigmak(j,k),
% mixweight
%
%PMTKauthor Hannes Bretschneider
%PMTKmodified Matt Dunham
%%
[mu, Sigma, mixweight, EMargs] = process_options(varargin, ...
    'mu0'        , []  , ...
    'Sigma0'     , []  ,...
    'mixweight0' , []  );
%% extract missing data
N       = size(data, 1); 
iscont  = (types=='c');
isdiscr = ~iscont;
dataC   = data(:, iscont);
dataD   = data(:, isdiscr);
dCont   = sum(iscont);
dDiscr  = sum(isdiscr);
%% Relabel discrete features
labels = cell(1, dDiscr);
nStates = zeros(1, dDiscr);
for j=1:dDiscr
    x            = dataD(:, j);
    l            = unique(x(~isnan(x)));
    x(~isnan(x)) = arrayfun(@(a)find(l==a),x(~isnan(x)));
    dataD(:, j)  = x;
    labels{j}    = l;
    nStates(j)   = length(l);
end
C              = max(nStates);
dataMissingC   = isnan(dataC);
missingRowsC   = find(any(dataMissingC,2) == 1);
dataMissingD   = isnan(dataD);
missingRowsD   = find(any(dataMissingD,2) == 1);
ndxMiss        = find(isnan(dataD));
[iMiss jMiss]  = ind2sub(size(dataD), ndxMiss);
dataD(ndxMiss) = 1+round((nStates(jMiss)-1)'.*rand(length(ndxMiss),1));

model = structure(nStates, labels, C, K, types, dCont, dDiscr,...
    mu, Sigma, mixweight, dataMissingC, missingRowsC, dataMissingD, ...
    missingRowsD, N);
X = {dataC, dataD};
[model, loglikHist] = emAlgo(model, X, @init, @estep, @mstep, EMargs{:});
end

function model = init(model, data, restartNum) %#ok
%% Initialize
dataC   = data{1};
nStates = model.nStates; 
K       = model.K;
dDiscr  = model.dDiscr;
dCont   = model.dCont;
n       = size(dataC, 1); 
beta    = zeros(model.C, dDiscr, K);
if isempty(model.mu) || isempty(model.Sigma)
    mu = zeros(dCont, K);
    Sigma = zeros(dCont, K);
    for k=1:K
        i           = ceil(n*rand); %pick a random vector
        proto       = dataC(i, :)';
        h           = isnan(proto); % hidden values
        proto(h)    = nanmeanPMTK(dataC(:, h));
        mu(:, k)    = proto;
        Sigma(:, k) = nanvarPMTK(dataC);
        
        for j=1:dDiscr
            beta(1:nStates(j), j, k) = normalize(rand(nStates(j), 1));
        end
    end
end
if isempty(model.mixweight)
    model.mixweight = normalize(ones(1,K));
end
model.mu    = mu;
model.Sigma = Sigma;
model.beta  = beta; 
end

function [ess, loglik] = estep(model, data)
%% Compute the expected sufficient statistics
dataC  = data{1};
dataD  = data{2};
N      = model.N; 
mu     = model.mu;
Sigma  = model.Sigma;
K      = model.K;
beta   = model.beta;
C      = model.C; 
dDiscr = model.dDiscr;
dCont  = model.dCont; 
dataMissingC = model.dataMissingC; 
missingRowsD = model.missingRowsD;
logrik = zeros(N, K);
logmix = log(model.mixweight+eps);
for k=1:K
    modelGaussK.mu    = mu(:, k); 
    modelGaussK.Sigma = diag(Sigma(:, k)+1e-10);
    modelDiscrK.T     = beta(:,:,k); 
    modelDiscrK.K     = C;
    modelDiscrK.d     = dDiscr;
    logpGauss         = gaussLogprob(modelGaussK, dataC);
    logpDiscr         = discreteLogprob(modelDiscrK, dataD);
    logrik(:, k)      = logmix(k) + logpGauss  + logpDiscr;
end
[logrik, ll] = normalizeLogspace(logrik);
rik          = exp(logrik);
loglik       = sum(ll);
XC           = dataC';

muik = zeros(dCont, K); % muik(:,k) = sum_i r(i,k) E[xi | zi=k, xiv]
V = zeros(dCont, K);
expVals = zeros(dCont,1); % temporary storage
expProd = zeros(dCont,1);
for k=1:K
    muk = mu(:,k);
    Sigmak = Sigma(:,k);
    for i=1:N
        u = dataMissingC(i,:); % unobserved entries
        o = ~u;
        expVals(u) = muk(u);
        expVals(o) = XC(o,i);
        expProd(u) = expVals(u).^2 + Sigmak(u);
        expProd(o) = expVals(o).^2;
        muik(:,k)  = muik(:,k) + rik(i,k)*expVals;
        V(:,k)     = V(:,k) + rik(i,k)*expProd;
    end
end
for m=1:length(missingRowsD);
    i = missingRowsD(m);
    u = isnan(dataD(i,:));
    betaW = zeros(C, dDiscr);
    for k=1:K
        betaW = betaW + rik(i,k)*beta(:,:,k);
    end
    expVals = pickModeClass(betaW);
    dataD(i,u) = expVals(u);
end
rk = sum(rik, 1); 
for j=1:dDiscr
    for c=1:C
        for k=1:K % this can probably be vectorized
            beta(c, j, k) = sum((rik(:, k).*(dataD(:, j)==c)))/rk(k);
        end
    end
end

ess = structure(rk, V, beta, muik);
end

function model = mstep(model, ess)
%% Maximize
K     = model.K; 
mu    = model.mu;
Sigma = model.Sigma;
V               = ess.V;
muik            = ess.muik;
rk              = ess.rk; 
model.beta      = ess.beta; 
model.mixweight = normalize(rk);
for k=1:K
    mu(:,k) = muik(:,k)/rk(k);
    Sigma(:,k) = (V(: ,k) - rk(k)*mu(:,k).^2)/rk(k);
end
Sigma(Sigma<1e-15) = 1e-15;
model.mu    = mu;
model.Sigma = Sigma;

end

function modeClass = pickModeClass(beta)
beta = beta';
mode = max(beta,[],2);
beta = bsxfun(@minus, beta, mode);
beta = (beta==0);
modeClass = arrayfun(@(i)find(beta(i,:)==1,1),1:size(beta,1));
end
