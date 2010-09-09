function logp = hmmLogprob(model, X)
% logp(i) = log p(X{i} | model), X{i} is 1*T
% if X is a single sequence, we compute logp = log p( {X} | model)

% This file is from pmtk3.googlecode.com

X = cellwrap(X);
nobs = numel(X);
logp = zeros(nobs, 1);
pi = model.pi;
A = model.A;
for i=1:nobs
    logB = mkSoftEvidence(model.emission, X{i}); 
    [logB, scale] = normalizeLogspace(logB'); 
    B    = exp(logB'); 
    logp(i) = hmmFilter(pi, A, B);
    logp(i) = logp(i) + sum(scale); 
end

end
