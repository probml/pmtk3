function logp = gaussHmmLogprob(model, X)
% logp(i) = log p(X{i} | model), X{i} is D*T
% if X is a single sequence, we compute logp = log p( {X'} | model)
if ~iscell(X)
    X = {X'};
end
nobs = numel(X);
logp = zeros(nobs, 1);
for i=1:nobs
    logp(i) = gaussHmmInfer(model, X{i}');
end

end