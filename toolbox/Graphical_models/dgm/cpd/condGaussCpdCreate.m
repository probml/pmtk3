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
nstates = cpd.nstates; 
prior = cpd.prior; 
mu = cpd.mu;
Sigma = cpd.Sigma; 
for k = 1:nstates
    logp = logp + gaussInvWishartLogprob(prior, mu(:, k), Sigma(:, :, k));
end
end