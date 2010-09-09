function [model, logev] = linregFitBayesZellnerPrior(X, y, g, preproc) %#ok
% Bayesian inference for a linear regression model using Zellner's g prior

% This file is from pmtk3.googlecode.com


[model.preproc, X] = preprocessorApplyToTrain(preproc, X);
[N,D] = size(X);
[Q,R] = qr(X,0);
wmle = R\(Q'*y); % posterior mean
Rinv = inv(R); % upper triangular, easy to invert
C = Rinv*Rinv'; % posterior covariance
XtXinv = C;
%XtXinv = pinv(X'*X);
%wmle = XtXinv * y;
sfac = g/(g+1); % shrinkage factor
model.wN = sfac*wmle;
model.VN = sfac * XtXinv;
model.aN = N/2;
s2 = norm(y-X*wmle)^2;
model.bN = s2/2 + 1/(2*(g+1)) * wmle'*X'*X*wmle;


if nargout >= 2
  logev = -(D+1)/2*log(g+1) -N/2*log(pi) + gammaln(N/2) ...
    -N/2*log(y'*y - sfac*y'*X*XtXinv*X'*y);
end
end % end of main function

