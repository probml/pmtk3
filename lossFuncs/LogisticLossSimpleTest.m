function [nll,g,H,T] = LogisticLossSimpleTest(w,X,y)
% Negative log likelihood for binary logistic regression
% w: d*1
% X: n*d
% y: n*1, should be -1 or 1

%PMTKauthor Mark Schmidt
%PMTKmodified Kevin Murphy

[n,p] = size(X);

Xw = X*w;
yXw = y.*Xw;
y01 = (y+1)/2;
mu = sigmoid(Xw);
nll = -sum(y01 .* log(mu) + (1-y01) .* log(1-mu));

nll2 = sum(mylogsumexp([zeros(n,1) -yXw]));
assert(approxeq(nll, nll2))


if nargout > 1
  g = X'*(mu-y01);
  if nargout > 2
    sig = 1./(1+exp(-yXw));
    g2 = -X.'*(y.*(1-sig));
  else
    g2 = -X.'*(y./(1+exp(yXw)));
  end
  assert(approxeq(g,g2))
end

if nargout > 2
  H = X'*diag(mu.*(1-mu))*X;
  H2 = X.'*diag(sparse(sig.*(1-sig)))*X;
  assert(approxeq(H,H2))
end

