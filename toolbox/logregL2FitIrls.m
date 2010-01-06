function [w, C] = logregL2IRLS(X, y, lambda)
% Iteratively reweighted least squares for logistic regression
%
% Rows of X contain data. Do not add a column of 1s.
% y(i) = -1 or +1
% lambda is optional strength of L2 regularizer
%
% Returns w, a row vector, 1st component is offset term
% and C, the asymptotic covariance matrix

% Based on code by David Martin, modified by Kevin Murphy

if nargin < 3, lambda = 0; end
n = size(X,1);
X = [ones(n,1) X];
d = size(X,2);
w = zeros(d,1); 
iter = 0;
tol = 1e-6; 
maxIter = 100;
nll = inf;
done = false;
lambdaVec = lambda*ones(d,1);
lambdaVec(1) = 0; % Don't penalize bias
funObj = @(w) penalizedL2(w, @LogisticLoss, lambdaVec, X, y);
while ~done
   iter = iter + 1;
   nll_prev = nll;
   [nll, g, H] = funObj(w);
   w = w - H\g; % Newton step
   if abs((nll-nll_prev)/(nll+nll_prev)) < tol, done = true; end;
   if iter > maxIter
      warning('did not converge'); done = true;
   end
end;
[nll, g, H] = funObj(w); %#ok
C = inv(H);


