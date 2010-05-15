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

logjoint = bsxfun(@plus, loglik, log(classPrior(:)'));
logpost  = bsxfun(@minus, logjoint, logsumexp(logjoint, 2));
post = exp(logpost);
yhat = maxidx(post,[],2);

end