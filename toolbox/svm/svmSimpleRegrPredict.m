function yhat = svmSimpleRegrPredict(model, Ktest)
yhat = Ktest*model.alpha + model.bias;
end