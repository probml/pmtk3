function [wn, Sn] = normalEqnsBayes(X, y, Lam0, w0, sigma)
% Numerically stable solution to posterior mean and covariance 
% under Gaussian prior N(w | w0, Lam0^{-1}), where sigma is noise std
% wn is the ridge (MAP) estimate, Sn is its covariance

% This file is from pmtk3.googlecode.com



if all(Lam0==0)
  [Q,R] = qr(X,0);
  wn = R\(Q'*y); % OLS
  Rinv = inv(R);
  Sn = sigma^2*Rinv*Rinv';
  return
end

[Lam0root] = chol(Lam0);
% use pseudo data trick
Xtilde = [X/sigma; Lam0root];
ytilde = [y/sigma; Lam0root*w0];
[Q,R] = qr(Xtilde, 0);
wn = R\(Q'*ytilde);

if nargout >= 2
  Rinv = inv(R);
  Sn = Rinv*Rinv';
end

if false  % naive way, for debugging
  s2 = sigma^2;
  Sninv = Lam0 + (1/s2)*(X'*X);
  Sn2 = inv(Sninv);
  wn2 = Sn2*(Lam0*w0 + (1/s2)*X'*y);
  assert(approxeq(Sn,Sn2))
  assert(approxeq(wn,wn2))
end

end 
