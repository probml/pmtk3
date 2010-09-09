function [yhat, post] = discrimAnalysisPredict(model, Xtest)
% Apply Bayes rule with Gaussian class-conditional densities.
% Computes post(i,c) = P(y=c|x(i,:), params)
% and yhat(i) = arg max_c post(i,c)

% This file is from pmtk3.googlecode.com



[N, d] = size(Xtest);
classPrior = model.classPrior;
Nclasses = length(model.classPrior);
loglik = zeros(N, Nclasses);
for c=1:Nclasses
    switch lower(model.type)
        case 'linear'
            loglik(:,c) = gaussLogprob(model.mu(:,c), model.SigmaPooled, Xtest);
        case {'qda', 'quadratic'}
            loglik(:, c) = gaussLogprob(model.mu(:,c), model.Sigma(:,:,c), Xtest);
        case 'diag'
            loglik(:, c) = gaussLogprob(model.mu(:,c), model.SigmaDiag(:,c), Xtest);
        case 'shrunkencentroids'
            loglik(:, c) = gaussLogprob(model.mu(:,c), model.SigmaPooledDiag, Xtest);
        case 'rda'
            beta = model.beta(:,c);
            gamma = -1/2*model.mu(:,c)'*beta;
            loglik(:,c) = exp(Xtest*beta + gamma);
        otherwise
            error(['unrecognized type ' model.covType])
    end
end

logjoint = bsxfun(@plus, loglik, log(classPrior(:)'));
logpost  = bsxfun(@minus, logjoint, logsumexp(logjoint, 2));
post = exp(logpost);
yhat = maxidx(post,[],2);
if isfield(model, 'support')
    yhat = setSupport(yhat, model.support);
end

end
