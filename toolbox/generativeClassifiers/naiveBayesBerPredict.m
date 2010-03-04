function [yhat, py] = naiveBayesBerPredict(model, Xtest)
% Apply a Naive Bayes classifier with Bernoulli features
% yhat(i) = argmax_c p(y=c|Xtest(i,:), theta(c,:)), in 1:C
% py(i,c) = p(y=c|xi, params)

theta = model.theta; classPrior = model.classPrior;
computeProb = (nargout >= 2);
[Ntest,D] = size(Xtest);
C  = size(theta,1);
if nargin < 3, classPrior = (1/C)*ones(1,C); end
logPrior = log(classPrior);
loglik  = zeros(1,C);
yhat = zeros(Ntest, 1);
py = zeros(Ntest, 1);
for i=1:Ntest
    for c=1:C
        thetaC = theta(c,:);
        bitmask = Xtest(i,:);
        loglik(c) = sum(bitmask .* log(thetaC) + (1-bitmask) .* log(1-thetaC));
    end
    logPost = loglik + logPrior;
    yhat(i) = argmax(logPost);
    if computeProb
        py(i) = exp(normalizeLogspace(logPost));
    end
end

end