function [muPost, SigmaPost, logZ, lambda] = varInferLogisticGaussCanonical(...
  y, W, b, muPrior, SigmaPriorInv, varargin)
% Use a variational approximation to infer a Gaussian posterior 
% given a Gaussian prior and a logistic likelihood
% 
% p(x(1:q) | y(1:p)) propto N(x(1:q)|muPrior, SigmaPrior) * p(y|x)
% where p(y|x) = prod_{i=1}^p  sigma( ystar(i) W(:,i)' * x(:) + b(i) )
% where ystar(i) = 2 y(i) - 1  (y(i) = 0,1  so ystar(i) = -1,+1)
%
% logZ = log p(y) = log int_x p(x,y) 
%
% If there are missing values in y, set them to NaN, and they will
% be dropped from the likelihood

% This file is from pmtk3.googlecode.com


% The variational approximation to the logistic function
% can be expressed as a canonical Gaussian CPD
% as explained in "A Variational Approximation for Bayesian Networks
% with Discrete and Continuous Latent Variables", K Murphy, UAI'99

% To enable comparison with varInferLogisticGauss,
% we can fixed the number of iterations to be the same

[fixedNumIter, maxIter] = process_options(varargin, ...
  'fixedNumIter', false, 'maxIter', 3);

log2pi = log(2*pi);

[q p] = size(W); % q is the size of the latent space, p is the size of the observable

if nargin < 4
  muPrior = zeros(q,1);
  SigmaPrior = eye(q);
end

y = y(:);

% If there are missing values, we will treat them as 0s for convenience,
% but will not send their likelihood contribution up to the latent Gaussian
% prior, so their values will be ignored
visNdx = find(~isnan(y));
hidNdx = find(isnan(y));
y(hidNdx) = 0; 

% initialize variational param 
xi = (2*y-1) .* (W'*muPrior + b);
ndx = find(xi==0);
xi(ndx) = 0.01*rand(size(ndx));

Kprior = SigmaPriorInv; % inv(SigmaPrior);
hprior = Kprior*muPrior;
gprior = 0.5*logdet(Kprior) -(q/2)*log2pi -0.5*muPrior'*Kprior*muPrior;

maxIter = 3; % usually needs 2-3
logZold = -inf;
%iter = 1;
thresh = 1e-10;

for iter=1:maxIter
  lambda = (0.5-sigmoid(xi)) ./ (2*xi);
  
  tmp2 = log(sigmoid(xi));
  % log[ 1/(1+exp(-x)) ] = 0 - log[1 + exp(-x)]
  %    = -log[exp(log(1) + exp(-x)]
  tmp = -logsumexp([zeros(p,1) -xi], 2);
  assert(approxeq(tmp2, tmp))
  
  glik = tmp + (y-0.5).*b - 0.5*xi + lambda.*(b.^2 - xi.^2);
  hlik = W*diag( y-0.5 + 2*lambda.*b);
  u = -2*lambda; u(hidNdx) = 0;
  Klik_sum = W*diag(u) * W'; % sum_{visible features j} W(:,j) u(j) W(:,j)'

  gpost = gprior + sum(glik(visNdx));
  hpost = hprior + sum(hlik(:,visNdx),2);
  Kpost = Kprior + Klik_sum;

  SigmaPost = inv(Kpost);
  muPost = SigmaPost * hpost;
  
  % update variational params
  tmp = diag(W'*(SigmaPost + muPost*muPost') * W);
  tmp2 = 2*(W*diag(b))'*muPost;
  xi = sqrt(tmp + tmp2 + b.^2);
  
  % log marginal likelihood - this should increase at every iteration
  logZ = gpost + 0.5*(q*log2pi - logdet(Kpost) + hpost'*SigmaPost*hpost);

  delta = logZ - logZold;
  %fprintf('infer iter %d, logZ = %10.6f, delta = %10.6f\n', iter, logZ, delta);
  if (delta < 0) & (abs(delta) > 1e-3)
    error(sprintf('logZ decreased from %10.6f to %10.6f', logZold, logZ))
  end
  if ~fixedNumIter && (delta/abs(logZold) < thresh) 
    %fprintf('converged after %d iter\n', iter);
    break;
  end
  %iter = iter + 1;
  logZold = logZ;
end

