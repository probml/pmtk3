function CPD = condGaussCpdCreate(mu, Sigma, varargin)
%% Create a conditional Gaussian distribution for use in a graphical model
%
% mu is a matrix of size d-by-nstates
% Sigma is of size d-by-d-by-nstates
%
% 'prior' is a Gauss-inverseWishart distribution, namely, a struct with
% fields  mu, Sigma, dof, k
% Set 'prior' to 'none' to do mle. 
%%

% This file is from pmtk3.googlecode.com

prior = process_options(varargin, 'prior', []); 
d = size(Sigma, 1); 
if isempty(prior) 
      prior.mu    = zeros(1, d);
      prior.Sigma = 0.1*eye(d);
      prior.k     = 0.01;
      prior.dof   = d + 1; 
end
if isvector(Sigma)
   Sigma = permute(rowvec(Sigma), [1 3 2]);  
end
nstates = size(Sigma, 3); 
if size(mu, 2) ~= nstates && size(mu, 1) == nstates
    mu = mu';
end
CPD = structure(mu, Sigma, nstates, d, prior); 
CPD.cpdType    = 'condGauss'; 
CPD.fitFn      = @condGaussCpdFit; 
CPD.fitFnEss   = @condGaussCpdFitEss;
CPD.essFn      = @condGaussCpdComputeEss;
CPD.logPriorFn = @logPriorFn;
CPD.rndInitFn  = @rndInit;
end

function cpd = rndInit(cpd)
%% randomly initialize
d = cpd.d;
nstates = cpd.nstates;
cpd.mu = randn(d, nstates);
Sigma = zeros(d, d, nstates);
for i=1:nstates
    Sigma(:, :, i) = randpd(d) + 2*eye(d); 
end
cpd.Sigma = Sigma; 
end

function logp = logPriorFn(cpd)
%% calculate the logprior
logp = 0;
prior = cpd.prior; 
if ~isempty(prior) && isstruct(prior)
nstates = cpd.nstates; 
mu = cpd.mu;
Sigma = cpd.Sigma; 
for k = 1:nstates
    logp = logp + gaussInvWishartLogprob(prior, mu(:, k), Sigma(:, :, k));
end
end
end

function ess = condGaussCpdComputeEss(cpd, data, weights, B)
%% Compute the expected sufficient statistics for a condGaussCpd
% data is nobs-by-d
% weights is nobs-by-nstates; the marginal probability of the discrete
% parent for each observation. 
% B is ignored, but required by the interface, (since mixture emissions use
% it). 
%%
d       = cpd.d; 
nstates = cpd.nstates; 
wsum    = sum(weights, 1);
xbar    = bsxfun(@rdivide, data'*weights, wsum); %d-by-nstates
XX      = zeros(d, d, nstates);
for j=1:nstates
    Xc          = bsxfun(@minus, data, xbar(:, j)');
    XX(:, :, j) = bsxfun(@times, Xc, weights(:, j))'*Xc;
end
ess = structure(xbar, XX, wsum); 
end

function cpd = condGaussCpdFitEss(cpd, ess)
%% Fit a condGaussCpd given expected sufficient statistics
% ess is a struct containing wsum, XX, and xbar
% cpd is a condGaussCpd as created by e.g condGaussCpdCreate
%
%%
wsum    = ess.wsum;
XX      = ess.XX;
xbar    = ess.xbar;
d       = cpd.d;
nstates = cpd.nstates;
prior   = cpd.prior;
if ~isstruct(prior) || isempty(prior) % do mle
    cpd.mu    = reshape(xbar, d, nstates);
    cpd.Sigma = bsxfun(@rdivide, XX, reshape(wsum, [1 1 nstates]));
else % do map
    kappa0 = prior.k;
    m0     = prior.mu(:);
    nu0    = prior.dof;
    S0     = prior.Sigma;
    mu     = zeros(d, nstates);
    Sigma  = zeros(d, d, nstates);
    for k = 1:nstates
        xbark          = xbar(:, k);
        XXk            = XX(:, :, k);
        wk             = wsum(k);
        mn             = (wk*xbark + kappa0*m0)./(wk + kappa0);
        a              = (kappa0*wk)./(kappa0 + wk);
        b              = nu0 + wk + d + 2;
        Sprior         = (xbark-m0)*(xbark-m0)';
        Sigma(:, :, k) = (S0 + XXk + a*Sprior)./b;
        mu(:, k)       = mn;
    end
    cpd.mu    = mu;
    cpd.Sigma = Sigma;
end
end

function cpd = condGaussCpdFit(cpd, Z, Y)
%% Fit a conditional Gaussian CPD
% Z(i) is the state of the parent Z in observation i.
% Y(i, :) is the ith 1-by-d observation of the child corresponding to Z(i)
% 
% By default we lightly regularize the parameters so we are doing map
% estimation, not mle. The Gauss-invWishart prior is set by 
% condGaussCpdCreate. 
%
%  cpd.mu is a matrix of size d-by-nstates
%  cpd.Sigma is of size d-by-d-by-nstates
%%
d = cpd.d; 
Z = colvec(Z); 
prior = cpd.prior; 
nstates = cpd.nstates; 
if ~isstruct(prior) || isempty(prior) % do mle
    cpd.mu    = partitionedMean(Y, Z, nstates)';
    cpd.Sigma = partitionedCov(Y, Z,  nstates); 
else  % map
    mu = zeros(d, nstates);
    Sigma = zeros(d, d, nstates);
    for s = 1:nstates
        m              = gaussFit(Y(Z == s, :), prior);
        mu(:, s)       = m.mu(:);
        Sigma(:, :, s) = m.Sigma;
    end
    cpd.mu = mu;
    cpd.Sigma = Sigma; 
end
end
