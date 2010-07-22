function logp = hmmLogprob(model, X)
% logp(i) = log p(X{i} | model), X{i} is 1*T
% if X is a single sequence, we compute logp = log p( {X} | model)
%PMTKlatentModel hmm
X = cellwrap(X);
nobs = numel(X);
logp = zeros(nobs, 1);
pi = model.pi;
A = model.A;
for i=1:nobs
    B = mkSoftEvidence(model.emission, X{i}); 
    logp(i) = hmmFilter(pi, A, B);
end

end