function logp = gaussHmmLogprob(model, X)
% logp(i) = log p(X | model)
if ~iscell(X)
    X = {X'};
end
nobs = numel(X);
logp = zeros(nobs, 1);
for i=1:nobs
    logp(i) = gaussHmmInfer(model, X{i}');
end

end