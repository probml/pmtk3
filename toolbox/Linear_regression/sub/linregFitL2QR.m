function w = linregFitL2QR(X, y, lambda)
% Ridge regression using QR
% lambda can be a vector

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

end