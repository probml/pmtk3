function [f,g] = SimultaneousSquaredError(W,X,Y)
% w(feature,1)
% X(instance,feature)
% y(instance,1)

W = reshape(W,size(X,2),size(Y,2));

XW = X*W;
res = XW-Y;
f = sum(res(:).^2);

if nargout > 1
    g = 2*(X.'*res);
    g = g(:);
end