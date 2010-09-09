function yhat = svmQPregPredict(model, Xtest)
% Return SVM regression predictions

% This file is from pmtk3.googlecode.com

Ktest = model.kernelFn(Xtest, model.X, model.kernelParam);
yhat = Ktest*model.alpha + model.bias;
end
