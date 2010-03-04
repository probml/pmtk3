function model = laplaceFit(X)
% Fit univariate Lapalce (double exponential) distribution by MLE

model.mu = median(X);
N = length(X);
model.b = sum(abs(X-model.mu))/N;

end