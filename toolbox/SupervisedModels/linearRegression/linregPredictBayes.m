function [yhat, sigma2Hat] = linregPredictBayes(model, X)
% Posterior predictive for linear regression model

% This file is from pmtk3.googlecode.com

[X] = preprocessorApplyToTest(model.preproc, X);
if isfield(model, 'netlab')
  [yhat, sigma2Hat] = linregPredictNetlab(model, X);
  return;
end
wN = model.wN; VN = model.VN;
yhat = X*wN;

if nargout >= 2
  if isfield(model, 'beta') % known variance
    %  posterior is Gaussian
    sigma2Hat = (1/model.beta) + diag(X*VN*X');
  else
    [N] = size(X,1);
    % posterior is student
    aN = model.aN; bN = model.bN;
    Sigma = bN/aN * (eye(N) + X*VN*X');
    dof = 2*aN;
    sigma2Hat = diag( (dof/(dof-2)) * Sigma);
  end
end

end % end of main function

