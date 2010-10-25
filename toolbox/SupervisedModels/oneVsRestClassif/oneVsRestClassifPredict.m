function [yhat, conf] = oneVsRestClassifPredict(model, X, predFn)
% Predict multiclass labels from a one vs the rest classifier
% conf(i,c) is the "confidence" of instance i being in class c it is not a
% probabiltiy, but is monotonically related to p(y=c|x(i,:), theta)

% This file is from pmtk3.googlecode.com

N = size(X, 1);
C = numel(model.modelClass);
score = zeros(N, C);
for c=1:C
    score(:, c) = predFn(model.modelClass{c}, X);
end
[conf, yhat] = max(score, [], 2);


end
