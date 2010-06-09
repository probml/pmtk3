function [ yhat post ] = RDApredict( model, X )
% Predict regularized disciminant analysis

%PMTKauthor Hannes Bretschneider

N = size(X, 1);
K = model.size(2);

post = NaN(N,K);
for k=1:K
    betaK = model.beta{k};
    gammaK = -1/2*model.mu{k}'*betaK + log(model.classPrior(k));
    post(:,k) = exp(X*betaK + gammaK);
end

post = normalize(post, 2);
yhat = maxidx(post, [], 2);
end

