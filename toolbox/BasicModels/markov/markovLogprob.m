function logp = markovLogprob(model, X)
% logp(i)       = log p(X(i, :) | model.pi, model.A)
% model.pi(j)   = p(S(1) = j)              - dist over starting states -
% model.A(j, k) = p(S(t) = k | S(t-1) = j) -  state transition matrix  - 
%
% where S(t) denotes the state at time step t.
%
% X(m, n) is in 1:length(model.pi), i.e. 1:nstates

% This file is from pmtk3.googlecode.com

N = size(X, 1);
logA = log(model.A + eps);
logPi = colvec(log(model.pi + eps));
nstates = length(logPi);
logPrior = logPi(X(:, 1)); 

logp = zeros(N, 1);
for i=1:N
    Njk = accumarray([X(i, 1:end-1)', X(i, 2:end)'], 1, [nstates, nstates]);
    logp(i) = sum(sum(Njk.*logA));
end
logp = logp + logPrior; 
end

