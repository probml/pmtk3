function model = gaussFit(X)
% Fit a Gaussian via MLE
model.mu = mean(X);
model.Sigma = cov(X);
end