%% Simple test of hmmFit with Gaussian observations
load data45
data = [train4'; train5'];
d = 13;
prior.mu = ones(1, d);
prior.Sigma = 0.1*eye(d);
prior.k = d;
prior.dof = prior.k + 1;
model = hmmFit(data, 2, 'gauss', 'verbose', true, 'piPrior', [3 2], ...
    'emissionPrior', prior, 'nRandomRestarts', 3)


X = hmmSample(model, 200, 10);
m2 = hmmFit(X, 5, 'gauss', 'verbose', true);

