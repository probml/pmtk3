function [muPost, SigmaPost, logZ, lambda] = varInferLogisticGauss(y, W, b, muPrior, SigmaPriorInv, computeLoglik)
% Use a variational approximation to infer a Gaussian posterior 
% given a Gaussian prior and a logistic likelihood for single case
%
% y(t) is {0,1}, t=1:T (num outputs)
% W is K*T where K is num latent dims
% b is T*1
% muPrior is K*1
% SigmaPrior is K*K
% 
% Uses the Jaakkola-Jordan bound
% For details, see "Probabilistic visualization of high-dimensional
% binary data", Tipping NIPS 1998

% This file is from pmtk3.googlecode.com

% Using process_options inside a tight inner loop is slow
%[maxIter, computeLoglik] = process_options(varargin, ...
%  'maxIter', 3, 'computeLoglik', (nargout >= 3));
maxIter = 3;

y = colvec(y);
if any(isnan(y))
  [muPost, SigmaPost, logZ, lambda] = varInferLogisticGaussMissing(y, W, b, muPrior, SigmaPriorInv, computeLoglik);
  return;
end


[q p] = size(W);
debug = 0;

% initialize variational param 
xi = (2*y-1) .* (W'*muPrior + b);
ndx = find(xi==0);
xi(ndx) = 0.01*rand(size(ndx));

SigmaInv = SigmaPriorInv; %inv(SigmaPrior);
for iter=1:maxIter
  lambda = (0.5-sigmoid(xi)) ./ (2*xi);

  tmp = W*diag(lambda)*W';
  SigmaPost = inv(SigmaInv - 2*tmp);

  %{
  if debug
    tmpB = zeros(q,q);
    for i=1:p
      tmpB = tmpB + lambda(i) * W(:,i) * W(:,i)';
    end
    assert(approxeq(tmp, tmpB))
  end
  %}
  
  tmp = y-0.5 + 2*lambda.*b;
  tmp2 = sum(W*diag(tmp), 2);
  muPost = SigmaPost*(SigmaInv*muPrior + tmp2);
  
  %{
  if debug
    tmp2B = zeros(q,1);
    for i=1:p
      tmp2B = tmp2B + (y(i)-0.5)*W(:,i) + 2*lambda(i)*b(i)*W(:,i);
    end
    assert(approxeq(tmp2, tmp2B))
  end
  %}
  
  tmp = diag(W'*(SigmaPost + muPost*muPost') * W);
  tmp2 = 2*(W*diag(b))'*muPost;
  xi = sqrt(tmp + tmp2 + b.^2);
  
  %{
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
  %}
  
  if ~computeLoglik
    logZ = 0;
  else
    % Computing normalization constant is slow
    lam = -lambda;
    % -ve sign needed because Tipping
    % uses different sign convention for lambda to Emt/Bishop/Murphy
    A = diag(2*lam);
    invA = diag(1./(2*lam));
    bb = -0.5*ones(p,1);
    c = -lam .* xi.^2 - 0.5*xi + log(1+exp(xi));
    ytilde = invA*(bb + y);
    B = W'; % T*K
    logconst1 = -0.5*sum(log(lam/pi));
    %assert(approxeq(logconst1, 0.5*logdet(2*pi*invA)))
    logconst2 = 0.5*ytilde'*A*ytilde - sum(c);
    logconst3 = gaussLogprob(B*muPrior + b, invA + B*SigmaPost*B', rowvec(ytilde));
    logZ = logconst1 + logconst2 + logconst3;
  end
end

end