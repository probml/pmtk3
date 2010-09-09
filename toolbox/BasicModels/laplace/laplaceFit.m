function model = laplaceFit(X)
% Fit univariate Laplace (double exponential) distribution by MLE

% This file is from pmtk3.googlecode.com

model.mu = median(X);
N = length(X);
model.b = sum(abs(X-model.mu))/N;

end
