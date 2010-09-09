function [yhat, py] = naiveBayesPredict(model, Xtest)
% Apply a Naive Bayes classifier 
% We currently assume binary features
% For Gaussian features, use discrimAnalysis.
% yhat(i) = argmax_c p(y=c|Xtest(i,:), theta(c,:)), in 1:C
% py(i,c) = p(y=c|xi, params)

% This file is from pmtk3.googlecode.com


vectorized = true;
if vectorized
    Ntest    = size(Xtest, 1);
    theta    = model.theta;
    C        = size(theta, 1);
    logPrior = log(model.classPrior + eps);
    logPost  = zeros(Ntest, C);
    logT     = log(theta + eps);
    logTnot  = log(1-theta + eps);
    XtestNot = not(Xtest);
    for c=1:C
        L1            = bsxfun(@times, logT(c, :), Xtest);
        L0            = bsxfun(@times, logTnot(c, :), XtestNot);
        logPost(:, c) = sum(L0 + L1, 2) + logPrior(c);
    end
    yhat = maxidx(logPost, [], 2);
    if nargout >= 2
        py = exp(normalizeLogspace(logPost));
    end
else
    theta = model.theta;
    classPrior = model.classPrior;
    computeProb = (nargout >= 2);
    [Ntest,D] = size(Xtest);
    C  = size(theta,1);
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
end
