function logp = hmmLogprob(model, X)
% logp(i) = log p(X{i} | model), X{i} is 1*T
% if X is a single sequence, we compute logp = log p( {X} | model)
%PMTKlatentModel hmm
if ~iscell(X)
    X = {X'};
end
nobs = numel(X);
logp = zeros(nobs, 1);
pi = model.pi;
A = model.A;
for i=1:nobs
    B = hmmMkLocalEvidence(model, X{i}'); 
    logp(i) = hmmFilter(pi, A, B);
end

end