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
% Sigma is of size d-by-d-by-nmix
% M is a matrix of size nstates-by-nmix, where nstates is the number of
% states of the parent. 
%
% 'prior' is a Gauss-inverseWishart distribution, namely, a struct with
% fields  mu, Sigma, dof, k. It also stores pseudoCounts, the prior for M,
% which must be the same size a M. 
%
% Set 'prior' to 'none' to do mle.
%
%%

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
%CPD.fitFn
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