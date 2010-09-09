function [model, output] = mlpRegressFitSchmidt(X, y, nHidden, lambda, options)
% Multi-layer perceptron for regression; fit using minFunc
% nHidden can be a vector of integers if there are multiple laters
% We currenly assume the same L2 regularizer on all the parameters
% output is the return value from minFunc

% This file is from pmtk3.googlecode.com


if nargin < 5, options.Display = 'none';  end
[N,D] = size(X);
X1 = [ones(N,1) X];
nVars = D+1;

nParams = nVars*nHidden(1);
for h = 2:length(nHidden);
    nParams = nParams+nHidden(h-1)*nHidden(h);
end
nParams = nParams+nHidden(end);

funObj = @(weights)MLPregressionLoss_efficient(weights,X1,y,nHidden);
w = randn(nParams,1); % initial params
[w,f,exitflag,output] = minFunc(@penalizedL2,w,options,funObj,lambda); %#ok

model.nParams = nParams;
model.w = w;
model.nHidden = nHidden;

yhat = mlpRegressPredictSchmidt(model, X);
model.sigma2 = mean((y(:) - yhat(:)).^2);

end
