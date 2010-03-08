function yhat = svmSimpleRegrPredict(model, Xtest)
Ktest = model.kernelFn(Xtest, model.X);
yhat = Ktest*model.alpha + model.bias;
end