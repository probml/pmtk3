function [yhat, f] = svmQPclassifPredict(model, Xtest)
% Return SVM classification predictions 
% yhat(i) = -1 or 1
% f(i) = signed distance to separating hyperplane

% This file is from pmtk3.googlecode.com

Ktest = model.kernelFn(Xtest, model.X, model.kernelParam); 
[Ntest, Ntrain] = size(Ktest); %#ok
H = repmat(model.y(:)', Ntest, 1) .* Ktest;
f = H*model.alpha + model.bias;
yhat = sign(f);
%yhat = convertLabelsTo01(yhat);
end
