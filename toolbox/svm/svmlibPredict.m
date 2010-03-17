function yhat = svmlibPredict(model, Xtest)

model = rmfield(model, 'C');
model = rmfield(model, 'engine');
n = size(Xtest, 1);
yhat = svmpredict(zeros(n, 1), Xtest, model);
end

