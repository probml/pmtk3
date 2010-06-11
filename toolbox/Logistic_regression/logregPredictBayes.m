function [yhat, p, pCI] = logregPredictBayes(model, X)
% yhat(i) = argmax_c p(y=c| X(i,:), wMean), converted to label space of model
% p(i, c) = p(y=c | X(i,:), wMean) % Plug in approximation
% For binary outputs, we can get a more refined probability using
% Monte Carlo:
% pCI(i, 1:3) = [Q5 Q50 Q95] = 5%, median and 95% quantiles of p(y=1|X(i,:))
% A column of 1s is added to X if this was done at training time


w = model.wN;
V = model.VN;
    
if isfield(model, 'preproc')
    [X] = preprocessorApplyToTest(model.preproc, X);
end

if model.binary
    p = sigmoid(X*w);
    yhat = p > 0.5;  % now in [0 1]
    yhat = setSupport(yhat, model.ySupport, [0 1]); 
else
    p = softmaxPmtk(X*w);
    yhat = maxidx(p, [], 2);
    C = size(p, 2); % now in 1:C
    yhat = setSupport(yhat, model.ySupport, 1:C); 
end

if (nargout >= 3) && (model.binary)
    Nsamples = 100;
    ws = gaussSample(w, V, Nsamples);
    N = size(X,1);
    pCI = zeros(N, 3);
    for i=1:N
      ps = 1 ./ (1+exp(-X(i,:)*ws')); % ps(s) = p(y=1|x(i,:), ws(s,:)) row vec
      tmp = sort(ps, 'ascend');
      Q5 = tmp(floor(0.05*Nsamples));
      Q50 = tmp(floor(0.50*Nsamples));
      Q95 = tmp(floor(0.95*Nsamples));
      pCI(i,:) = [Q5 Q50 Q95];
    end
end

    
end
