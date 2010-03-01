function [z, pz, ll] = mixStudentInfer(model, X)
% z(i) = argmax_k p(z=k|X(i,:), model) hard clustering
% pz(i,k) = p(z=k|X(i,:), model) soft responsibility
% ll(i) = log p(X(i,:) | model)  logprob of observed data

K = model.K;
N = size(X,1);
logPz = zeros(N, K);
logmix = log(model.mixweight+eps);
for k=1:K
  modelK.mu = model.mu(:, k); modelK.Sigma = model.Sigma(:, :, k);
  modelK.dof = model.dof(k);
  logPz(:, k) = logmix(k) +  studentLogprob(modelK, X);
end
z = maxidx(logPz, [], 2);
if nargout > 1
  [logPz, ll] = normalizeLogSpace(logPz);
  pz = exp(logPz);
end
