function [muPost, SigmaPost, lambda] = varInferLogisticGauss(y, W, b, muPrior, SigmaPrior, varargin)
% Use a variational approximation to infer a Gaussian posterior 
% given a Gaussian prior and a logistic likelihood
% 
% p(x(1:q) | y(1:p)) propto N(x(1:q)|muPrior, SigmaPrior) * p(y|x)
% where p(y|x) = prod_{i=1}^p  sigma( ystar(i) W(:,i)' * x(:) + b(i) )
% where ystar(i) = 2 y(i) - 1  (y(i) = 0,1  so ystar(i) = -1,+1)

% This file is from pmtk3.googlecode.com


[maxIter] = process_options(varargin, 'maxIter', 3);
[q p] = size(W);
debug = 0;

% initialize variational param 
xi = (2*y-1) .* (W'*muPrior + b);
ndx = find(xi==0);
xi(ndx) = 0.01*rand(size(ndx));

SigmaInv = inv(SigmaPrior);
for iter=1:maxIter
  lambda = (0.5-sigmoid(xi)) ./ (2*xi);

  tmp = W*diag(lambda)*W';
  SigmaPost = inv(SigmaInv - 2*tmp);

  if debug
    tmpB = zeros(q,q);
    for i=1:p
      tmpB = tmpB + lambda(i) * W(:,i) * W(:,i)';
    end
    assert(approxeq(tmp, tmpB))
  end
    
  tmp = y-0.5 + 2*lambda.*b;
  tmp2 = sum(W*diag(tmp), 2);
  muPost = SigmaPost*(SigmaInv*muPrior + tmp2);
  
  if debug
    tmp2B = zeros(q,1);
    for i=1:p
      tmp2B = tmp2B + (y(i)-0.5)*W(:,i) + 2*lambda(i)*b(i)*W(:,i);
    end
    assert(approxeq(tmp2, tmp2B))
  end
  
  tmp = diag(W'*(SigmaPost + muPost*muPost') * W);
  tmp2 = 2*(W*diag(b))'*muPost;
  xi = sqrt(tmp + tmp2 + b.^2);
  
  if debug
    tmptmp = SigmaPost + muPost*muPost';
    tmpB = zeros(p,1);
    tmp2B = zeros(p,1);
    for i=1:p
      tmpB(i) = W(:,i)'*tmptmp*W(:,i);
      tmp2B(i) = 2*b(i)*W(:,i)'*muPost;
    end
    assert(approxeq(tmp, tmpB))
    assert(approxeq(tmp2, tmp2B))
  end
end
  
%%%%%%%

function y=sigmoid(x)

y = 1./(1+exp(-x));
