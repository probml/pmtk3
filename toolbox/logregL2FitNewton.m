function model = logregL2FitNewton(X, y, lambda, includeOffset)
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
if nargin < 4, includeOffset = true; end
y = y(:);
y = canonizeLabels(y); % ensure 1,2
y = 2*(y-1)-1; % map to -1,+1

[N nVars] = size(X);
if includeOffset
  X = [ones(N,1) X];
  lambda = lambda*ones(nVars+1,1);
  lambda(1) = 0; % Don't penalize bias term
  winit = zeros(nVars+1,1);
else
  lambda = lambda*ones(nVars,1);
  winit = zeros(nVars,1);
end


d = size(X,2);
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
[nll, g, H] = funObj(w); %#ok
C = inv(H);

model.w = w;
model.C = C;
model.includeOffset = includeOffset;


