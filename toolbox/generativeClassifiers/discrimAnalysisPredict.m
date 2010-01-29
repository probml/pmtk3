function [yhat, post] = discrimAnalysisPredict(model, Xtest)
%  apply Bayes rule with Gaussian class-conditioanl densities.
% Computes post(i,c) = P(y=c|x(i,:), params) 
% and yhat(i) = arg max_c post(i,c)


[N, d] = size(Xtest);
classPrior = model.classPrior;
Nclasses = length(model.classPrior);
loglik = zeros(N, Nclasses);
for c=1:Nclasses
  switch model.type
    case 'linear'
      loglik(:,c) = gaussLogpdf(Xtest, model.mu(:, c)', model.SigmaPooled);
    case 'quadratic'
      loglik(:,c) = gaussLogpdf(Xtest, model.mu(:, c)', model.Sigma(:, :, c));
    otherwise
      error(['unrecognized type ' model.type])
  end
end
N = size(Xtest,1);
logjoint = loglik + repmat(log(classPrior(:)'), N, 1);
logpost = logjoint - repmat(logsumexp(logjoint,2), 1, Nclasses);
post = exp(logpost);
[junk, yhat] = max(post,[],2); 
