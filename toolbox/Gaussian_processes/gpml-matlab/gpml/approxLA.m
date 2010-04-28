function [alpha, sW, L, nlZ, dnlZ] = approxLA(hyper, covfunc, lik, x, y)

% Laplace approximation to the posterior Gaussian Process.
% The function takes a specified covariance function (see covFunction.m) and
% likelihood function (see likelihoods.m), and is designed to be used with
% binaryGP.m. See also approximations.m.
%
% Copyright (c) 2006, 2007 Carl Edward Rasmussen and Hannes Nickisch 2007-03-29

persistent best_alpha best_nlZ        % copy of the best alpha and its obj value
tol = 1e-6;                   % tolerance for when to stop the Newton iterations

n = size(x,1);
K = feval(covfunc{:}, hyper, x);                % evaluate the covariance matrix

if any(size(best_alpha) ~= [n,1])   % find a good starting point for alpha and f
  f = zeros(n,1); alpha = f;                                     % start at zero
  [lp,dlp,d2lp] = feval(lik,y,f,'deriv');   W=-d2lp;
  Psi_new = lp; best_nlZ = Inf; 
else
  alpha = best_alpha; f = K*alpha;                             % try best so far
  [lp,dlp,d2lp] = feval(lik,y,f,'deriv');   W=-d2lp;
  Psi_new = -alpha'*f/2 + lp;         
  if Psi_new < -n*log(2)                                 % if zero is better ..
    f = zeros(n,1); alpha = f;                                      % .. go back
    [lp,dlp,d2lp] = feval(lik,y,f,'deriv'); W=-d2lp; 
    Psi_new = -alpha'*f/2 + lp;
  end
end
Psi_old = -Inf;                                    % make sure while loop starts

while Psi_new - Psi_old > tol                        % begin Newton's iterations
  Psi_old = Psi_new; alpha_old = alpha; 
  sW = sqrt(W);                     
  L = chol(eye(n)+sW*sW'.*K);                            % L'*L=B=eye(n)+sW*K*sW
  b = W.*f+dlp;
  alpha = b - sW.*solve_chol(L,sW.*(K*b));
  f = K*alpha;
  [lp,dlp,d2lp,d3lp] = feval(lik,y,f,'deriv'); W=-d2lp;

  Psi_new = -alpha'*f/2 + lp;
  i = 0;
  while i < 10 && Psi_new < Psi_old               % if objective didn't increase
    alpha = (alpha_old+alpha)/2;                      % reduce step size by half
    f = K*alpha;
    [lp,dlp,d2lp,d3lp] = feval(lik,y,f,'deriv'); W=-d2lp;
    Psi_new = -alpha'*f/2 + lp;
    i = i+1;
  end 
end                                                    % end Newton's iterations

sW = sqrt(W);                                                    % recalculate L
L  = chol(eye(n)+sW*sW'.*K);                             % L'*L=B=eye(n)+sW*K*sW
nlZ = alpha'*f/2 - lp + sum(log(diag(L)));      % approx neg log marg likelihood
    
if nlZ < best_nlZ                                            % if best so far ..
  best_alpha = alpha; best_nlZ = nlZ;           % .. then remember for next call
end

if nargout >= 4                                        % do we want derivatives?
  dnlZ = zeros(size(hyper));                    % allocate space for derivatives
  Z = repmat(sW,1,n).*solve_chol(L, diag(sW));
  C = L'\(repmat(sW,1,n).*K);
  s2 = 0.5*(diag(K)-sum(C.^2,1)').*d3lp;
  for j=1:length(hyper)
    dK = feval(covfunc{:}, hyper, x, j);
    s1 = alpha'*dK*alpha/2-sum(sum(Z.*dK))/2;
    b  = dK*dlp;
    s3 = b-K*(Z*b);
    dnlZ(j) = -s1-s2'*s3;
  end
end
