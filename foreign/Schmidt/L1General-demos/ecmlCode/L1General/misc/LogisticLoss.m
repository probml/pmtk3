function [nll,g,H] = LogisticLoss(w,X,y)
% w(feature,1)
% X(instance,feature)
% y(instance,1)

[n,p] = size(X);

Xw = X*w;
yXw = y.*Xw;

nll = sum(mylogsumexp([zeros(n,1) -yXw]));

if nargout > 1
    if nargout > 2
        sig = 1./(1+exp(-yXw));
        g = -X'*(y.*(1-sig));
    else
        g = -X'*(y.*(1-(1./(1+exp(-yXw)))));
    end
end

if nargout > 2
    H = X.'*diag(sparse(y.*sig.*(1-sig).*y))*X;
end