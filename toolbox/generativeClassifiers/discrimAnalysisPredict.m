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
      modelC.mu = model.mu(:, c)'; modelC.Sigma = model.SigmaPooled;
      loglik(:,c) = gaussLogprob(modelC, Xtest);
    case 'quadratic'
      modelC.mu = model.mu(:, c)'; modelC.Sigma = model.Sigma(:, :, c);
      loglik(:, c) = gaussLogprob(modelC, Xtest);
    otherwise
      error(['unrecognized type ' model.type])
  end
end
N = size(Xtest,1);
logjoint = loglik + repmat(log(classPrior(:)'), N, 1);
logpost = logjoint - repmat(logsumexp(logjoint,2), 1, Nclasses);
post = exp(logpost);
[junk, yhat] = max(post,[],2); 

end