%% Simple test of hmmFitEm with Gaussian observations
%
%%
load data45
data = [train4'; train5'];
d = 13;

% test with a bogus prior
if 0
    prior.mu = ones(1, d);
    prior.Sigma = 0.1*eye(d);
    prior.k = d;
    prior.dof = prior.k + 1;
else 
    prior.mu = [1 3 5 2 9 7 0 0 0 0 0 0 1];
    prior.Sigma = randpd(d) + eye(d);
    prior.k = 12;
    prior.dof = 15;
end

model = hmmFitEm(data, 2, 'gauss', 'verbose', true, 'piPrior', [3 2], ...
    'emissionPrior', prior, 'nRandomRestarts', 3)


X = hmmSample(model, 200, 10);
m2 = hmmFitEm(X, 5, 'gauss', 'verbose', true);

