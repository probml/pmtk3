function [muPost, SigmaPost, loglik] = binaryFAinferLatent(model, data, varargin)
% Infer distribution over latent factors given observed data
%
% data(n,j) in {0,1} or {1,2}
% NaN's not supproted
%
%
% Output:
% mu(:,n)
% Sigma(:,:,n)
% loglikCases(n)

[N,T] = size(data);
y = canonizeLabels(data)-1; % {0,1}
W = model.W;
b = model.b;
[K, T2] = size(W);
assert(T==T2);
muPrior = model.muPrior;
SigmaPriorInv = inv(model.SigmaPrior);
muPost = zeros(K,N);
loglik = zeros(1,N);
if nargout >= 2
  SigmaPost = zeros(K,K,N);
else
  SigmaPost = [];
end
for n=1:N
  [muPost(:,n), Sigma, logZ] = ...
    varInferLogisticGauss(y(n,:)', W, b, muPrior, SigmaPriorInv);
  if nargout >= 2, SigmaPost(:,:,n) = Sigma; end
  loglik(n) = logZ;
end


end

