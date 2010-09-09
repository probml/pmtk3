function logp = logregLogprob(model, X, y)
%% log p(y(i)|X(i,:), model)

% This file is from pmtk3.googlecode.com

[yhat, P] = logregPredict(model, X); 
Y = oneOfK(y, numel(model.ySupport)); 
logp = sum(Y.*log(P), 2); 
end
