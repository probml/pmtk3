function [W, b, muPost, logZ] = tippingEM(Y, q)

% Y(i,n) is the n'th example - each COLUMN is an example
% q is the number of latent variables

% This file is from pmtk3.googlecode.com


[p N] = size(Y);

% initialization
W = 0.1*randn(q,p); % W(j,i) for Xj -> Yi
b = 0.01*randn(p,1);
muPrior = zeros(q,1);
SigmaPrior = eye(q);

iter = 1;
thresh = 1e-3;
maxIter = 30;
muPost = zeros(q,N);
logZold = -inf;

debug = false;
timCan = 0; timMom = 0; % timing for the 2 methods

while 1
  % E step
  q1 = q+1;
  S2 = zeros(q1,q1,p);
  S1 = zeros(q1,p);
  logZ = 0;
  for n=1:N
   % The canonical function also returns the loglikelihood
    [muPost(:,n), SigmaPost, lambda, LL] = ...
      varInferLogisticGaussCanonical(Y(:,n), W, b, muPrior, SigmaPrior);
    logZ = logZ + LL;

    if debug 
      % Check Tippings formulas agree with Murphy UAI'99
      % Only equivalent if we use the same number of iterations inside varInfer
       tic;
      [muPost(:,n), SigmaPost, lambda, LL] = ...
        varInferLogisticGaussCanonical(Y(:,n), W, b, muPrior, SigmaPrior, ...
        'fixedNumIter', true, 'maxIter', 3);
      timCan = timCan + toc;
      
      tic;
      [muPost2(:,n), SigmaPost2, lambda2] = ...
        varInferLogisticGauss(Y(:,n), W, b, muPrior, SigmaPrior, 'maxIter', 3);
      timMom = timMom + toc;
      assert(approxeq(muPost(:,n), muPost2(:,n)))
      assert(approxeq(SigmaPost, SigmaPost2))
      assert(approxeq(lambda, lambda2))
    end
    
    mu = muPost(:,n);
    for i=1:p % can we vectorize this?
      Sn = SigmaPost + mu*mu';
      Mn = zeros(q1, q1);
      Mn(1:q,1:q) = Sn;
      Mn(q+1,1:q) = mu';
      Mn(1:q,q+1) = mu;
      Mn(q+1,q+1) = 1;
      S2(:,:,i) = S2(:,:,i) + 2*lambda(i)*Mn;
      S1(:,i) = S1(:,i) + (Y(i,n) - 0.5) * [mu; 1];
    end
  end
  
  % M step
  %what = zeros(q1, 1);
  for i=1:p
    what = -S2(:,:,i) \ S1(:,i);
    W(:,i) = what(1:q);
    b(i) = what(q+1);
  end

  % Converged?
  delta = logZ - logZold;
  %fprintf('EM iter %d, logZ = %10.6f, relative delta = %10.6f\n', iter, logZ, delta/abs(logZold));
  if delta < 0
    error(sprintf('logZ decreased from %10.6f to %10.6f', logZold, logZ))
  end
  if (delta/abs(logZold) < thresh) | (iter > maxIter)
    break;
  end
  iter = iter + 1;
  logZold = logZ;
end

if debug
  timCan
  timMom
end
