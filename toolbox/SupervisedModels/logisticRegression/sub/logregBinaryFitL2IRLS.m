function model = logregBinaryFitL2IRLS(X, y, lambda, includeOffset)
% Iteratively reweighted least squares for logistic regression
%
% Rows of X contain data. Do not add a column of 1s.
% y must be binary and will be transformed into [-1 1]
% lambda is optional strength of L2 regularizer
%
% model.C is the asymptotic covariance matrix

% This file is from pmtk3.googlecode.com


% Based on code by David Martin, modified by Kevin Murphy

if nargin < 3, lambda = 0; end
if nargin < 4, includeOffset = true; end
[y, model.ySupport] = setSupport(y, [-1, 1]);

[N nVars] = size(X);
if includeOffset
  X = [ones(N, 1) X];
  lambda = lambda*ones(nVars + 1, 1);
  lambda(1) = 0; % Don't penalize bias term
  winit = zeros(nVars+1, 1);
else
  lambda = lambda*ones(nVars, 1);
  winit = zeros(nVars, 1);
end

w = winit;
iter = 0;
tol = 1e-6; 
maxIter = 100;
nll = inf;
done = false;
funObj = @(w) penalizedL2(w, @LogisticLossSimple, lambda, X, y);
while ~done
   iter = iter + 1;
   nll_prev = nll;
   [nll, g, H] = funObj(w);
   w = w - H\g; % Newton step
   if convergenceTest(nll, nll_prev, tol), done = true; end
   if iter > maxIter
      warning('did not converge'); done = true;
   end
end;
[nll, g, H] = funObj(w); 
C = inv(H);

model.w = w;
model.C = C;
model.includeOffset = includeOffset;


end
