function L = softmaxLog(X,W)
% L(n,:) = log softmax(W * X(n,:)') 
eta = X*W;
Z = sum(exp(eta), 2);
nclasses = size(eta,2);
L = eta - repmat(log(Z), 1, nclasses);
end