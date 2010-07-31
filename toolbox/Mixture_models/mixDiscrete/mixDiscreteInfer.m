function [z, pz, ll] = mixDiscreteInfer(model, X)
% z(i) = argmax_k p(z=k|X(i,:), model) hard clustering
% pz(i,k) = p(z=k|X(i,:), model) soft responsibility
% ll(i) = log p(X(i,:) | model)  logprob of observed data
[nstates, d, nmix] = size(model.T); %#ok
logT = log(model.T + eps);
[n] = size(X,1);
Lijk = zeros(n, d, nmix);
for j=1:d
    Lijk(:, j, :) = logT(X(:, j), j, :);
end
w = rowvec(model.mixweight);
logRik = bsxfun(@plus, log(w+eps), squeeze(sum(Lijk, 2)));
z = maxidx(logRik, [], 2);
if nargout > 2
    ll = logsumexp(logRik, 2);
    pz = exp(bsxfun(@minus, logRik, ll));
end
end