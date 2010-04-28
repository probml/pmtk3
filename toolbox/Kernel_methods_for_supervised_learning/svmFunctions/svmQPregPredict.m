function yhat = svmQPregPredict(model, Xtest)
Ktest = model.kernelFn(Xtest, model.X, model.kernelParam);
yhat = Ktest*model.alpha + model.bias;
end