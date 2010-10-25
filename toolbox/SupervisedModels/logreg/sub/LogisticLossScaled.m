function [nll,g,H] = LogisticLossScaled(w,X,y)
% Average negative log likelihood for binary logistic regression
% w: d*1
% X: n*d
% y: n*1, should be -1 or 1

% This file is from pmtk3.googlecode.com


N = size(X,1);
switch nargout
  case 1
    [nll] = LogisticLossSimple(w,X,y);
    nll = nll/N;
  case 2,
    [nll,g] = LogisticLossSimple(w,X,y);
    nll = nll/N; g = g/N;
   case 3,
    [nll,g,H] = LogisticLossSimple(w,X,y);
    nll = nll/N; g = g/N; H = H/N;
end

end
