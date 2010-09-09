function lambdas = linregLambdas(X, y, regType, nlambdas)
% Choose a reasonable range of lambdas to cv over for linear regression
% regType should be 'L2' or 'L1' or 'scad'

% This file is from pmtk3.googlecode.com


if nargin < 4, nlambdas  = 10; end

switch lower(regType)
  case 'l1'
    lambdaMax = lambdaMaxLasso(X, centerCols(y));
    lambdas = linspace(1e-5, lambdaMax, nlambdas);
  case {'l2', 'scad'}
    lambdas = 10.^(linspace(-3,2, nlambdas));
end

end


