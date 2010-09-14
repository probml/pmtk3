function [postMean, postCov] = ppcaInferLatent(model, X)
% Probabilistic PCA - compute posterior on Z
% postMean(i,:) = E[Z|X(i,:)]
% postCov(:,:) is the same for all i

% This file is from pmtk3.googlecode.com

mu = model.mu; W = model.W; sigma2 = model.sigma2;
evals = model.evals; evecs = model.evecs;

K = size(W,2);
N = size(X,1);
Lam = evals(1:K)';
U = evecs(:, 1:K);
Minv = diag(1./Lam);
if 0% debugging
  assert(approxeq(Minv, inv(W'*W + sigma2*eye(K))))
end
postCov = sigma2*Minv;
%MinvWT = (1./Lam) .* sqrt(Lam - sigma2) * U';
MinvWT = Minv*W';
postMean = (MinvWT*(X'-repmat(mu(:),1,N)))';


end
