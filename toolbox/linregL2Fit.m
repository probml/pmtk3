
function model = linregL2Fit(X, y, lambda, includeOffset)
% Ridge regression
% adds a column of 1s by default, so w=[w0 w1:D] (col vector)
if nargin < 4, includeOffset = true; end
[N,D] = size(X);
if includeOffset
   X = [ones(N,1) X];
   D1  = D+1;
else 
   D1 = D;
end
if lambda == 0
  w = X\y;
else
  lambdaVec = lambda*ones(D1,1);
  if includeOffset
    lambdaVec(1) = 0; % Don't penalize bias term
  end
  XX  = [X; diag(sqrt(lambdaVec))];
  yy = [y; zeros(D1,1)];
  w  = XX \ yy; % QR
end

model.w = w;
model.includeOffset = includeOffset;
model.sigma2 = var((X*w - y).^2); % MLE


