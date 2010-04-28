function model = gaussFit(X)
    model.mu = mean(X); 
    model.Sigma = cov(X);
end