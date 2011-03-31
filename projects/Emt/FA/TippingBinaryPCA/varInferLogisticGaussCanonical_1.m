function [muPost, SigmaPost, lambda, logZ] = varInferLogisticGaussCanonical(y, W, b, muPrior, SigmaPrior, isdiag)
% Use a variational approximation to infer a Gaussian posterior 
% given a Gaussian prior and a logistic likelihood
% 
% p(x(1:q) | y(1:p)) propto N(x(1:q)|muPrior, SigmaPrior) * p(y|x)
% where p(y|x) = prod_{i=1}^p  sigma( ystar(i) W(:,i)' * x(:) + b(i) )
% where ystar(i) = 2 y(i) - 1  (y(i) = 0,1  so ystar(i) = -1,+1)
%
% logZ = log p(y) = log int_x p(x,y) 

if nargin < 5
    isdiag = 0;
end 
if isdiag
    v = diag(W);
end 

log2pi = log(2*pi);

[q p] = size(W); % q is the size of the latent space, p is the size of the observable
assert(q==length(muPrior))
y = y(:);

% initialize variational param 
xi = (2*y-1) .* (W'*muPrior + b);
ndx = find(xi==0);
xi(ndx) = 0.01*rand(size(ndx));

Kprior = inv(SigmaPrior);
hprior = Kprior*muPrior;
gprior = 0.5*logdet(Kprior) -(q/2)*log2pi -0.5*muPrior'*Kprior*muPrior;

maxIter = 5; % usually needs 2-3
logZold = -inf;
iter = 1;
thresh = 1e-10;

while 1
  lambda = (0.5-sigmoid(xi)) ./ (2*xi);
  
  %tmp2 = log(sigmoid(xi));
  % log[ 1/(1+exp(-x)) ] = 0 - log[1 + exp(-x)]
  %    = -log[exp(log(1) + exp(-x)]
  tmp = -logsumexp([zeros(p,1) -xi], 2);
  
  glik = tmp + (y-0.5).*b - 0.5*xi + lambda.*(b.^2 - xi.^2);
  gpost = gprior + sum(glik);
  
  if ~isdiag
    hlik = W*diag( y-0.5 + 2*lambda.*b);
    hpost = hprior + sum(hlik,2);
  else
    hlik = diag(W).*(y-0.5 + 2*lambda.*b);
    hpost = hprior + hlik;
  end
  
  if ~isdiag
    Klik_sum = (W*diag(-2*lambda)) * W';
    Kpost = Kprior + Klik_sum;
  else
      Klik_sum = diag(W).*(-2*lambda).*diag(W);
      Kpost = Kprior + diag(Klik_sum);
  end

  SigmaPost = inv(Kpost);
  muPost = SigmaPost * hpost;
  
  % update variational params
  if ~isdiag
    tmp = diag(W'*(SigmaPost + muPost*muPost') * W);
    tmp2 = 2*(W*diag(b))'*muPost;
  else
     tmp = diag(W).*diag(SigmaPost+muPost*muPost').*diag(W);
     tmp2= 2*diag(W).*b.*muPost;
  end
  xi = sqrt(tmp + tmp2 + b.^2);
  
  % log marginal likelihood - this should increase at every iteration
  logZ = gpost + 0.5*(q*log2pi - logdet(Kpost) + hpost'*SigmaPost*hpost);

  delta = logZ - logZold;
  %fprintf('infer iter %d, logZ = %10.6f, delta = %10.6f\n', iter, logZ, delta);
  if (delta < 0) & (abs(delta) > 1e-3)
    warning(sprintf('logZ decreased from %10.6f to %10.6f', logZold, logZ))
  end
  if (delta/abs(logZold) < thresh) | (iter > maxIter)
    break;
  end
  iter = iter + 1;
  logZold = logZ;
end

