function [yhat, p1] = logregKernelPredict(model, X)
% p1(i) = p(y=1|X(i,:), w)
% yhat - same space as model.ySupport

X = mkUnitVariance(center(X)); % important for kernel performance

K = kernelBasis(X, model.basis, model.kernelType, model.kernelParam);

p1 = sigmoid(K*model.w);
yhat01 = p1>=0.5;
yhat(yhat01 == 0) = model.ySupport(1);
yhat(yhat01 == 1) = model.ySupport(2); 
yhat = colvec(yhat); 



