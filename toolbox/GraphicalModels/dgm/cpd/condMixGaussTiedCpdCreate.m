function CPD = condMixGaussTiedCpdCreate(mu, Sigma, M, varargin)
%% Create a local CPD representing a tied mixture of Gaussians
% where the state of the hidden parent influences only the mixing weights,
% not mu and Sigma. When used as the observation model for an HMM, it is
% called a semi-continuous or tied-mixture HMM.
%
%  p(Xt|St=i) = sum_m p(Mt=m|St=i) gauss(Xt|mu(m), Sigma(m))
%
%% Inputs
%
% mu is a matrix of size d-by-nmix 
%
% Sigma is of size d-by-d-by-nmix
%
% M is a matrix of size nstates-by-nmix, where nstates is the number of
% states of the parent: M(j, k) = p(Mt = k | St = j). Each *column* sums to
% one. 
%
% 'prior' is a Gauss-inverseWishart distribution, namely, a struct with
% fields  mu, Sigma, dof, k. It also stores pseudoCounts, the prior for M,
% which must be the same size a M. 
%
% Set 'prior' to 'none' to do mle.
%
%%

% This file is from pmtk3.googlecode.com

prior = process_options(varargin, 'prior', []);
[nstates, nmix] = size(M);
d = size(Sigma, 1);
if isempty(prior)
    prior.mu    = zeros(1, d);
    prior.Sigma = 0.1*eye(d);
    prior.k     = 0.01;
    prior.dof   = d + 1;
    prior.pseudoCounts = 2*ones(size(M));  
end

if isvector(Sigma)
    Sigma = permute(rowvec(Sigma), [1 3 2]);
end
if size(mu, 2) ~= nmix && size(mu, 1) == nmix
    mu = mu';
end
CPD = structure(mu, Sigma, M, nmix, nstates, d, prior);
CPD.cpdType    = 'condMixGaussTied';
%% 'methods'
CPD.fitFn      = @condMixGaussTiedCpdFit;
CPD.fitFnEss   = @condMixGaussTiedCpdFitEss;
CPD.essFn      = @condMixGaussTiedCpdComputeEss;
CPD.logPriorFn = @logPriorFn; 
CPD.rndInitFn  = @rndInit;
end

function logp = logPriorFn(cpd)
%% log prior
prior = cpd.prior; 
logp = 0;
if ~isempty(prior)&& isstruct(prior)
    nmix  = cpd.nmix;
    mu    = cpd.mu;
    Sigma = cpd.Sigma;
    for k = 1:nmix
        logp = logp + gaussInvWishartLogprob(prior, mu(:, k), Sigma(:, :, k));
    end
    logp = logp + log(cpd.M(:)+eps)'*(prior.pseudoCounts(:)-1);
end
end

function cpd = rndInit(cpd)
%% randomly initialize
d = cpd.d;
nstates = cpd.nstates;
nmix    = cpd.nmix; 
cpd.mu = randn(d, nmix);
Sigma = zeros(d, d, nmix);
for i=1:nmix
    Sigma(:, :, i) = randpd(d) + 2*eye(d); 
end
cpd.Sigma = Sigma; 
cpd.M = normalize(rand(nstates, nmix), 1);
end

function cpd = condMixGaussTiedCpdFit(cpd, Z, Y) % or perhaps (cpd, Z, M, Y)?
error('Fitting a condMixGaussTiedCpd given fully observed data is not yet supported'); 
end

function ess = condMixGaussTiedCpdComputeEss(cpd, data, gamma, B)
%% Compute the expected sufficient statistics for a condMixGaussTiedCpd
% data is nobs-by-d
% gamma is nobs-by-nstates: the marginal probability of the discrete
% parent for each observation.
%
% B is the soft evidence:  B(j, t) = p(X(:, t) | S(t) = j, localCPD)
% It is calculated if not specified. 
%
%%
[nobs, d] = size(data); 
nmix      = cpd.nmix; 
if nargin < 4
    logB = mkSoftEvidence(cpd, data'); 
    B    = exp(normalizeLogspace(logB')');  % B(j, t) = p(x_t | S(t) = j)
end
mu      = cpd.mu;    % [d nmix] 
Sigma   = cpd.Sigma; % [d d nmix]
M       = cpd.M;     % [nstates nmix]

logBmix = zeros(nobs, nmix); 
for k = 1:nmix
   logBmix(:, k) = gaussLogprob(mu(:, k), Sigma(:, :, k), data);  
end
Bmix  = exp(normalizeLogspace(logBmix)); 
% we account for the mixing weights on line 120

B(B==0) = 1; 
gamma = gamma./B'; % divide out message

                                            % line up dimensions
                                       % gamma    is [nobs nstates  1  ]
Mperm     = permute(M, [3, 1, 2]);     % Mperm    is [1    nstates nmix]
BmixPerm  = permute(Bmix, [1, 3, 2]);  % BmixPerm is [nobs    1    nmix]
gamma2    = msxfun(@times, gamma, Mperm, BmixPerm);  
% gamma2(t, j, k) = p(St = j, Mt = k | x_{1:T} )

Wjk  = squeeze(sum(gamma2, 1));  % [nstates nmix]
Rik  = squeeze(sum(gamma2, 2));  % [nobs    nmix]
Rk   = sum(Rik, 1); 
X    = data;                     % [nobs d]
XX   = zeros(d, d, nmix);
xbar = zeros(d, nmix);
for k = 1:nmix
    Xw          = bsxfun(@times, X, Rik(:, k)); % weight by responsibilities
    xbar(:, k)  = sum(Xw / Rk(k), 1)';          
    Xctr        = bsxfun(@minus, X, xbar(:, k)');
    XX(:, :, k) = bsxfun(@times, Xctr, Rik(:, k))'*Xctr;
end
ess = structure(xbar, XX, Wjk, Rk); 
end

function cpd = condMixGaussTiedCpdFitEss(cpd, ess)
%% Fit a condMixGaussTied CPD given expected sufficient statistics
% ess is a struct as returned by e.g. condMixGaussTiedComputeEss
% ess has fields xbar, XX, Wjk, Rk
%%
xbar = ess.xbar;
XX   = ess.XX;
Wjk  = ess.Wjk;
Rk   = ess.Rk; 

[d, d, nmix] = size(XX);
prior = cpd.prior; 
if ~isempty(prior) && isstruct(prior)
    pseudoCounts = prior.pseudoCounts;
    kappa0       = prior.k;
    m0           = prior.mu(:);
    nu0          = prior.dof;
    S0           = prior.Sigma;
    doMap        = true; 
else
    doMap = false;
end
%%
if doMap
    cpd.M = normalize(Wjk + pseudoCounts - 1, 1);
else
    cpd.M = normalize(Wjk, 1);
end
%%
Rk(Rk == 0) = 1; 
if ~doMap % mle
    cpd.mu    = xbar;
    cpd.Sigma = bsxfun(@rdivide, XX, permute(Rk(:), [3, 2, 1]));
else      
    Sigma = zeros(d, d, nmix);
    mu    = zeros(d, nmix);
    for k = 1:nmix
        mu(:, k)       = (Rk(k)*xbar(:, k) + kappa0*m0)./(Rk(k) + kappa0);
        a              = (kappa0*Rk(k))./(kappa0 + Rk(k));
        b              = nu0 + Rk(k) + d + 2;
        xbarC          = xbar(:, k) - m0;
        Sprior         = xbarC*xbarC';
        Sigma(: ,: ,k) = (S0 + XX(: , :, k) + a*Sprior)./b;
    end
    cpd.mu    = mu;
    cpd.Sigma = Sigma; 
end
end

