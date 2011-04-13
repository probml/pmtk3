function [muPost, SigmaPost, loglik] = binaryFAinferLatent(model, y, varargin)
% Infer distribution over latent factors given observed data
%
% y(n,t) in {0,1} or {1,2} or NaN
% Optional:
% 'x'  x(n,d) in real
%
%
% Output:
% mu(:,n)
% Sigma(:,:,n)
% loglikCases(n)

[computeLoglik, computeSigma, x] = process_options(varargin, ...
  'computeLoglik', (nargout >= 3), 'computeSigma', (nargout >= 2), 'x', []);

[N,T] = size(y);
y = canonizeLabels(y)-1; % {0,1}
W = model.W;
b = model.b;
[K, T2] = size(W);
assert(T==T2);
muPrior = model.muPrior;
SigmaPriorInv = inv(model.SigmaPrior);
muPost = zeros(K,N);
loglik = zeros(1,N);
if computeSigma
  SigmaPost = zeros(K,K,N);
else
  SigmaPost = [];
end
for n=1:N
  if ~isempty(x)
    switch model.inputType
      case 'linear'
        muPrior  = model.Win * x(n,:)';
      case 'logistic'
        muPrior = sigmoid(model.Win * x(n,:)');
    end
  end
  [muPost(:,n), Sigma, logZ] = ...
    varInferLogisticGauss(y(n,:)', W, b, muPrior, SigmaPriorInv, computeLoglik);
  if computeSigma, SigmaPost(:,:,n) = Sigma; end
  loglik(n) = logZ;
end


end

