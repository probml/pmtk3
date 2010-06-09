function [yhat, py] = naiveBayesGaussPredict(model, Xtest)
% Apply a Naive Bayes classifier with  Gaussian features
% yhat(i) = argmax_c p(y=c|Xtest(i,:), theta(c,:)), in 1:C
% py(i,c) = p(y=c|xi, params)

mu = model.mu; sigma = model.sigma; classPrior = model.classPrior;

[Ntest,D] = size(Xtest); 
C  = size(mu,1);
loglik  = zeros(Ntest,C);
for c=1:C
  dst = (Xtest - repmat(mu(c,:), Ntest, 1)).^2;
  sig = sigma(c,:);
  sig2 = repmat(sig.^2, Ntest, 1);
  tmp  = -dst./(2*sig2) - 0.5*log(sig2);
  loglik(:,c) = sum(tmp, 2); 
end
logPost = loglik + repmat(log(classPrior(:)'), Ntest, 1); %N,C
[junk, yhat] = max(logPost,[],2); %#ok
if nargout >= 2
  py = exp(normalizeLogspace(logPost));
end


end