function w = linregFitL2QR(X, y, lambda)
% Ridge regression using QR

if lambda == 0
  w = X\y;
else
  if isscalar(lambda)
    D = size(X,2);
    lambda = lambda*ones(D,1);
  end
  XX  = [X; diag(sqrt(lambda))];
  yy = [y; zeros(D,1)];
  w  = XX \ yy; 
end


