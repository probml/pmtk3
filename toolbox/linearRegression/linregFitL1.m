function model = linregFitL1(X, y, lambda, method, standardizeX)
% lasso (L1 penalized Linear Regression)     
 
if nargin < 4, method = 'lars'; end
if nargin < 5, standardizeX = true; end

if standardizeX
  % we should standardize the data since we are using a symmetric prior
  [X, model.Xmu] = center(X);
  [X, model.Xstnd] = mkUnitVariance(X);
end

% we can compute the offset using w0 = ybar - xbar'*w
% where w is computed on centered inputs and outputs
[y, ybar] = center(y);

switch lower(method)
  case 'shooting'
    w = linregFitL1Shooting(X, y, lambda);
  case 'lars'
    w = linregFitL1LarsSingleLambda(X, y, lambda);
  case 'interiorpoint'
    w = linregFitL1InteriorPoint(X, y, lambda);
  otherwise
    error(['unrecognized method ' method])
end

xbar = mean(X);
model.w0 = ybar - xbar*w;
model.w = w;
yhat = linregPredict(model, X);
model.sigma2 = var((yhat - y).^2); % MLE
