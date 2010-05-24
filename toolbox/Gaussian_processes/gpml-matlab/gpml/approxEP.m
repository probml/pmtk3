function [alpha, sW, L, nlZ, dnlZ] = approxEP(hyper, covfunc, lik, x, y)

% Expectation Propagation approximation to the posterior Gaussian Process.
% The function takes a specified covariance function (see covFunction.m) and
% likelihood function (see likelihoods.m), and is designed to be used with
% binaryGP.m. See also approximations.m. In the EP algorithm, the sites are 
% updated in random order, for better performance when cases are ordered 
% according to the targets.
%
% Copyright (c) 2006, 2007 Carl Edward Rasmussen and Hannes Nickisch 2007-07-24

persistent best_ttau best_tnu best_nlZ     % keep tilde parameters between calls
tol = 1e-3; max_sweep = 10;           % tolerance for when to stop EP iterations

n = size(x,1);
K = feval(covfunc{:}, hyper, x);                % evaluate the covariance matrix

% A note on naming: variables are given short but descriptive names in 
% accordance with Rasmussen & Williams "GPs for Machine Learning" (2006): mu
% and s2 are mean and variance, nu and tau are natural parameters. A leading t
% means tilde, a subscript _ni means "not i" (for cavity parameters), or _n
% for a vector of cavity parameters.

if any(size(best_ttau) ~= [n 1])      % find starting point for tilde parameters
  ttau = zeros(n,1);             % initialize to zero if we have no better guess
  tnu  = zeros(n,1);
  Sigma = K;                     % initialize Sigma and mu, the parameters of ..
  mu = zeros(n, 1);                    % .. the Gaussian posterior approximation
  nlZ = n*log(2);
  best_nlZ = Inf;   
else
  ttau = best_ttau;                    % try the tilde values from previous call
  tnu  = best_tnu;
  [Sigma, mu, nlZ, L] = epComputeParams(K, y, ttau, tnu, lik); 
  if nlZ > n*log(2)                                       % if zero is better ..
    ttau = zeros(n,1);                    % .. then initialize with zero instead
    tnu = zeros(n,1); 
    Sigma = K;                   % initialize Sigma and mu, the parameters of ..
    mu = zeros(n, 1);                  % .. the Gaussian posterior approximation
    nlZ = n*log(2);       
  end
end
nlZ_old = Inf; sweep = 0;                          % make sure while loop starts

while nlZ < nlZ_old - tol && sweep < max_sweep       % converged or max. sweeps?
    
  nlZ_old = nlZ; sweep = sweep+1;
  for i = randperm(n)       % iterate EP updates (in random order) over examples

    tau_ni = 1/Sigma(i,i)-ttau(i);      %  first find the cavity distribution ..
    nu_ni = mu(i)/Sigma(i,i)-tnu(i);            % .. parameters tau_ni and nu_ni

    % compute the desired raw moments m0, m1=hmu and m2; m0 is not used
    [m0, m1, m2] = feval(lik, y(i), nu_ni/tau_ni, 1/tau_ni);
    hmu = m1./m0;
    hs2 = m2./m0 - hmu^2;                        % compute second central moment
       
    ttau_old = ttau(i);                     % then find the new tilde parameters
    ttau(i) = 1/hs2 - tau_ni;   
    tnu(i) = hmu/hs2 - nu_ni;

    ds2 = ttau(i) - ttau_old;                   % finally rank-1 update Sigma ..
    si = Sigma(:,i);
    Sigma = Sigma - ds2/(1+ds2*si(i))*si*si';          % takes 70% of total time
    mu = Sigma*tnu;                                        % .. and recompute mu
        
  end
    
  [Sigma, mu, nlZ, L] = epComputeParams(K, y, ttau, tnu, lik);       % recompute
    % Sigma & mu since repeated rank-one updates can destroy numerical precision
end

if sweep == max_sweep
  disp('Warning: maximum number of sweeps reached in function approxEP')
end

if nlZ < best_nlZ                                            % if best so far ..
  best_ttau = ttau; best_tnu = tnu; best_nlZ = nlZ;      % .. keep for next call
end

sW = sqrt(ttau);                  % compute output arguments, L and nlZ are done
alpha = tnu-sW.*solve_chol(L,sW.*(K*tnu));

if nargout > 4                                         % do we want derivatives?
  dnlZ = zeros(size(hyper));                    % allocate space for derivatives
  F = alpha*alpha'-repmat(sW,1,n).*solve_chol(L,diag(sW)); 
  for j=1:length(hyper)
    dK = feval(covfunc{:}, hyper, x, j);
    dnlZ(j) = -sum(sum(F.*dK))/2;
  end
end


% function to compute the parameters of the Gaussian approximation, Sigma and
% mu, and the negative log marginal likelihood, nlZ, from the current site 
% parameters, ttau and tnu. Also returns L (useful for predictions).
function [Sigma, mu, nlZ, L] = epComputeParams(K, y, ttau, tnu, lik)

n = length(y);                                        % number of training cases
ssi = sqrt(ttau);                                         % compute Sigma and mu
L = chol(eye(n)+ssi*ssi'.*K);                            % L'*L=B=eye(n)+sW*K*sW
V = L'\(repmat(ssi,1,n).*K);
Sigma = K - V'*V;
mu = Sigma*tnu;

tau_n = 1./diag(Sigma)-ttau;               % compute the log marginal likelihood
nu_n  = mu./diag(Sigma)-tnu;                      % vectors of cavity parameters
nlZ   = sum(log(diag(L))) - sum(log(feval(lik, y, nu_n./tau_n, 1./tau_n)))   ...
       -tnu'*Sigma*tnu/2 - nu_n'*((ttau./tau_n.*nu_n-2*tnu)./(ttau+tau_n))/2 ...
       +sum(tnu.^2./(tau_n+ttau))/2-sum(log(1+ttau./tau_n))/2;
