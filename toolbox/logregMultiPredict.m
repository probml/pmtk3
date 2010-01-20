function [yhat, prob] = logregMultiPredict(X, W, addOnes)
% X is N*D
% W is D*C
% yhat(i) in {1,...,C} is most probable label
% prob(i,:) is distribution over classes
% A column of 1s is added to X by default

if nargin < 3, addOnes = true; end
N = size(X,1);
if addOnes
  X = [ones(N,1) X];
end
prob = softmax(X*W);
[junk, yhat] = max(prob,[],2); %#ok
