function [model] = mlpClassifFitSchmidt(X, y, nHidden, lambda, options)
% Multi-layer perceptron for BINARY regression; fit using minFunc
% nHidden can be a vector of integers if there are multiple laters
% We currenly assume the same L2 regularizer on all the parameters

% This file is from pmtk3.googlecode.com


if nargin < 5, options.Display = 'none';  end
y = (2*(canonizeLabels(y)-1))-1; % ensure -1,+1
[N,D] = size(X);
X = [ones(N,1) X];
nVars = D+1;

nParams = nVars*nHidden(1);
for h = 2:length(nHidden);
    nParams = nParams+nHidden(h-1)*nHidden(h);
end
nParams = nParams+nHidden(end);

funObj = @(weights)MLPbinaryLoss(weights,X,y,nHidden);
w = randn(nParams,1); % initial params
w = minFunc(@penalizedL2,w,options,funObj,lambda);

model.nParams = nParams;
model.w = w;
model.nHidden = nHidden;

end


