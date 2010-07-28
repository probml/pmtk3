function model = gaussFit(X, prior)
% Fit a Gaussian via mle / map
% 
% prior (optional) - parameters of a Gauss-inverseWishart distribution, 
%                    namely mu, Sigma, dof, k 
%
% PMTKsimpleModel gauss
%%
if nargin < 2 || isempty(prior) || strcmpi(prior, 'none') % mle
    mu = mean(X);
    Sigma = cov(X);
else % map
    
    [N, D] = size(X);
    xbar   = mean(X)';
    XX     = cov(X);
    kappa0 = prior.k;
    m0     = prior.mu(:);
    nu0    = prior.dof;
    S0     = prior.Sigma;
    mu     = (N*xbar + kappa0*m0)./(N + kappa0);
    a      = (kappa0*N)./(kappa0 + N);
    b      = nu0 + N + D + 2;
    Sprior = (xbar-m0)*(xbar-m0)';
    Sigma  = (S0 + XX + a*Sprior)./b;
    
    model.prior = prior; 
    
end
model.mu = mu;
model.Sigma = Sigma; 
model.modelType = 'gauss';
end