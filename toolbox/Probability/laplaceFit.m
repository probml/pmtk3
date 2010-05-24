function model = laplaceFit(X)
% Fit univariate Laplace (double exponential) distribution by MLE

model.mu = median(X);
N = length(X);
model.b = sum(abs(X-model.mu))/N;

end