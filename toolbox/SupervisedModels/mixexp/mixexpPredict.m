function varargout = mixexpPredict(model, X)
%% Predict using mixture of experts model 
% If the response y is real-valued, we return
% [mu, sigma2, post, muk, sigma2k] = mixexpPredict(model, X)
%   mu(i) = E[y | X(i,:)]
%   sigma2(i) = var[y | X(i,:)]
%  weights(i,k) = p(expert = k | X(i,:)
%  muk(i) = E[y | X(i,:), expert k]
%  sigma2k(i) = var[y | X(i,:), expert k]
%
% If the response y is categorical, we return
% [yhat, prob] = mixexpPredict(model, X)
%   yhat(i) = argmax p(y|X(i,:))
%   prob(i,c) = p(y=c|X(i,:))

% This file is from pmtk3.googlecode.com


[N,D] = size(X);
%X = standardize(X);
%X = [ones(N,1) X];
if isfield(model, 'preproc')
    [X] = preprocessorApplyToTest(model.preproc, X);
end
K = model.nmix;
if model.fixmix
  weights = repmat(model.mixweights, N, 1);
else
  weights = softmaxPmtk(X*model.Wq); % weights(n,q)
end
if model.classifier
  % implemented by JoAnne Ting
  prob = zeros(N, size(model.Wy,2));
  yhat_k = zeros(N, model.Nclasses, K);
  for k = 1:K
    yhat_k(:,:,k) = softmaxPmtk(X*model.Wy(:,:,k));
    % Weighted vote
    prob = prob + yhat_k(:,:,k) .* repmat(weights(:,k), 1, size(model.Wy,2));
  end
  yhat = maxidx(prob, [], 2);
  varargout{1} = yhat;
  varargout{2} = prob;
else
  % mean of a mixture model is given by
  % E[x] = sum_k pik muk
   %mu = sum(weights .* (X*model.Wy), 2);
  % variance of a mixture model is given by
  % sum_k pi_k [Sigmak + muk*muk'] - E[x] E[x]'
  muk = zeros(N,K); vk = zeros(N,K);
  mu = zeros(N,1); v = zeros(N,1);
  for k=1:K
    muk(:,k) = X*model.Wy(:,k);
    mu = mu + weights(:,k) .* muk(:,k);
    vk(:,k) = model.sigma2(k);
    v = v + weights(:,k) .* (vk(:,k) + muk(:,k).^2);
  end
  v = v-mu.^2;
  varargout{1} = mu;
  varargout{2} = v;
  varargout{3} = weights;
  varargout{4} = muk;
  varargout{5} = vk;
end
end


