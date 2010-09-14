function [Xrecon, rmse] = ppcaReconstruct(model, X)
% Compress X then reconstruct it in Xhat
% and return root mean squared error

% This file is from pmtk3.googlecode.com

mu = model.mu; W = model.W; 
[Z] = ppcaInferLatent(model, X);
N = size(X,1);
Xrecon = Z*W' + repmat(rowvec(mu), N,1);
err = (Xrecon - X);
rmse = sqrt(mean(err(:).^2));
    
end
