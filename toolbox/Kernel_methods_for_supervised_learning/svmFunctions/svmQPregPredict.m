function yhat = svmQPregPredict(model, Xtest)
% Return SVM regression predictions
Ktest = model.kernelFn(Xtest, model.X, model.kernelParam);
yhat = Ktest*model.alpha + model.bias;
end