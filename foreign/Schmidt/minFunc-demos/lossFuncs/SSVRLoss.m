function [f,g,H] = SSVMLoss(w,X,y,epsilon)
% w(feature,1)
% X(instance,feature)
% y(instance,1)

[n,p] = size(X);

Xw = X*w;
err1 = Xw - y - epsilon;
err2 = y - Xw - epsilon;

viol1 = find(err1 >= 0);
viol2 = find(err2 >= 0);

f = sum(err1(viol1).^2) + sum(err2(viol2).^2);

if nargout > 1
    g = zeros(size(w));
    if ~isempty(viol1)
        g = g + 2*X(viol1,:)'*err1(viol1);
    end
    if ~isempty(viol2)
        g = g - 2*X(viol2,:)'*err2(viol2);
    end
end

if nargout > 2
    H = zeros(p);
    if ~isempty(viol1)
        H = H + 2*X(viol1,:)'*X(viol1,:);
    end
    if ~isempty(viol2)
        H = H + 2*X(viol2,:)'*X(viol2,:);
    end
end

