function [nll,g,H] = LogisticLossSimple(w,X,y)
% Negative log likelihood for binary logistic regression
% w: d*1
% X: n*d
% y: n*1, should be -1 or 1

y01 = (y+1)/2;
mu = sigmoid(X*w);
nll = -sum(y01 .* log(mu) + (1-y01) .* log(1-mu));

if nargout > 1
  g = X'*(mu-y01);
end

if nargout > 2
  H = X'*diag(mu.*(1-mu))*X;
end

