function [nll,g,H] = ProbitLoss(w,X,y)
% w(feature,1)
% X(instance,feature)
% y(instance,1)

yXw = y.*(X*w)/sqrt(2);
erf_yXw = erf(full(yXw));
probit_yXw = (1/2)*(1+erf_yXw)+eps;
nll = -sum(log(probit_yXw));

if nargout > 1
        norm_yXw = (1/sqrt(2*pi))*exp(-yXw.^2);
        g = -X'*(y.*norm_yXw./probit_yXw);
end

if nargout > 2
    H = X'*diag(sparse(norm_yXw.*norm_yXw./probit_yXw.^2 + norm_yXw.*yXw.*sqrt(2)./probit_yXw))*X;
end
