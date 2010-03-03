function model = linregFitL2(X, y, lambda, method, standardizeX)
% Ridge regression

if nargin < 4, method = 'QR'; end
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
  case 'qr'
    w = linregFitL2QR(X, y, lambda);
  case 'minfunc'
    w = linregFitL2Minfunc(X, y, lambda);
  otherwise
    error(['unrecognized method ' method])
end

xbar = mean(X);
model.w0 = ybar - xbar*w;
model.w = w;
yhat = linregPredict(model, X);
model.sigma2 = var((yhat - y).^2); % MLE

end
