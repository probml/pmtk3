function [z, r, logSumRho, logr, Nk] = mixGaussBayesInfer(model, X)
% z(i) = argmax_k p(z=k|X(i,:), model) hard clustering
% pz(i,k) = p(z=k|X(i,:), model) soft responsibility
% ll(i) = log p(X(i,:) | model)  logprob of observed data
%
% Calculate responsibilities using Bishop eqn 10.67

% This file is from pmtk3.googlecode.com

[alpha, beta, entropy, invW, logDirConst, logLambdaTilde, logPiTilde,  ...
    logWishartConst, m, v, W] = ...
  structvals(model.postParams, 'alpha', 'beta', 'entropy', 'invW', ...
  'logDirConst', 'logLambdaTilde', 'logPiTilde', 'logWishartConst',...
  'm', 'v', 'W'); 
 
K = model.K;
[N,D] = size(X);

E = zeros(N,K); 
for k = 1:K
  XC = bsxfun(@minus, X, m(k,:));
  E(:,k) = D/(beta(k)) + v(k)*sum((XC*W(:,:,k)).*XC,2); % 10.64
end

logRho = repmat(logPiTilde + 0.5*logLambdaTilde, N,1) - 0.5*E;
logSumRho = logsumexp(logRho,2);
logr = logRho - repmat(logSumRho, 1,K);
r = exp(logr);
Nk = exp(logsumexp(logr,1));
z = maxidx(logr, [], 2);

end


