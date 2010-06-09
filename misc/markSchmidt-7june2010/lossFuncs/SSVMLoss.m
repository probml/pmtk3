function [f,g,H] = SSVMLoss(w,X,y)
% w(feature,1)
% X(instance,feature)
% y(instance,1)

[n,p] = size(X);

err = 1-y.*(X*w);
viol = find(err>=0);
f = sum(err(viol).^2);

if nargout > 1
    if isempty(viol)
        g = zeros(size(w));
    else
        g = -2*X(viol,:)'*(err(viol).*y(viol));
    end
end

if nargout > 2
    H = 2*X(viol,:)'*X(viol,:);
end

