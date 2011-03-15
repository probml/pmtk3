function model = gaussFit(X, prior)
% Fit a multivariate Gaussian via mle / map
% 
% model = gaussFit(X) % MLE
% model = gaussFit(X, 'map') % MAP with weak prior 
% model = gaussFit(X, prior) % MAP, where prior is a NIW model
%   with  params mu, Sigma, dof, k 
%
%%

% This file is from pmtk3.googlecode.com

[N, D] = size(X);
if nargin < 2 || isempty(prior) || strcmpi(prior, 'none') % mle
    mu = mean(X);
    Sigma = cov(X,1); % MLE
else
  if ischar(prior) && strcmpi(prior, 'map')
    clear prior;
    prior.mu = zeros(D,1); % m0
    prior.k = 0; % k0
    prior.Sigma = diag(var(X,1))/N; % S0
    prior.dof = D+2; % this ensures E[Sigma]=S0 
    model.prior = prior;
  end
  xbar   = mean(X)';
  XX     = cov(X,1);
  C = N*XX;
  kappa0 = prior.k;
  m0     = prior.mu(:);
  nu0    = prior.dof;
  S0     = prior.Sigma;
  
  muN     = (N*xbar + kappa0*m0)./(N + kappa0);
  kappaN = kappa0 + N;
  nuN = nu0 + N;
  SN = S0 + C + kappa0*m0*m0' - kappaN*muN*muN';
  
 
  mu = muN;
  %Sigma = SN/(nuN + D + 1); % marginal MAP estimate
  %Sigma = SN/(nuN + D + 2); % joint MAP estimate
  Sigma = SN/(nuN - D - 1); % posterior mean estimate
  
  %{
  a      = (kappa0*N)./(kappa0 + N);
  b      = nu0 + N + D + 2;
  Sprior = (xbar-m0)*(xbar-m0)';
  Sigma  = (S0 + XX + a*Sprior)./b; % ??
  %}
  
end
model.mu = mu;
model.Sigma = Sigma; 
model.modelType = 'gauss';
end
