function [yhat, sigma2Hat] = linregPredictBayes(model, X)
% Posterior predictive for linear regression model

[X] = preprocessorApplyToTest(model.preproc, X);
[N] = size(X,1);
wN = model.wN; VN = model.VN;
yhat = X*wN;

if nargout >= 2
  if isfield(model, 'beta') % known variance
    %  posterior is Gaussian
    sigma2Hat = (1/model.beta) + diag(X*VN*X');
  else
    % posterior is student
    aN = model.aN; bN = model.bN;
    Sigma = bN/aN * (eye(N) + X*VN*X');
    dof = 2*aN;
    sigma2Hat = diag( (dof/(dof-2)) * Sigma);
  end
end

end % end of main function

