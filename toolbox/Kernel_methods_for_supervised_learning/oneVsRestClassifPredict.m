function [yhat, conf] = oneVsRestClassifPredict(model, X, predFn)
% conf(i,c) is the "confidence" of instance i being in class c it is not a
% probabiltiy, but is monotonically related to p(y=c|x(i,:), theta)
N = size(X, 1);
C = numel(model.modelClass);
score = zeros(N, C);
for c=1:C
    score(:, c) = predFn(model.modelClass{c}, X);
end
[conf, yhat] = max(score, [], 2);

end