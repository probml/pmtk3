function [nll,g,H] = LogisticLossSimple(w,X,y)
% Negative log likelihood for binary logistic regression
% w: d*1
% X: n*d
% y: n*1, should be -1 or 1

% This file is from pmtk3.googlecode.com


y01 = (y+1)/2;
mu = sigmoid(X*w);
mu = max(mu, eps); % bound away from 0
mu = min(1-eps, mu); % bound away from 1
nll = -sum(y01 .* log(mu) + (1-y01) .* log(1-mu));

if nargout > 1
  g = X'*(mu-y01);
end

if nargout > 2
  H = X'*diag(mu.*(1-mu))*X;
end

end
