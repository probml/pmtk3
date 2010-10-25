function model = linregFitSimple(X, y, lambda)
% Ridge regression using QR

% This file is from pmtk3.googlecode.com

if lambda == 0
  w = X\y;
else
  D = size(X,2);
  if isscalar(lambda)
    lambda = lambda*ones(D,1);
  end
  XX  = [X; diag(sqrt(lambda))];
  yy = [y; zeros(D,1)];
  w  = XX \ yy; 
end
yhat = X*w;
sigma2 = var( (y-yhat) );
model = linregCreate(w, sigma2);
end
