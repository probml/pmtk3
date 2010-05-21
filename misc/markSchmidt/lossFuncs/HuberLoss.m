function [f,g,H,T] = HuberLoss(w,X,y,k)
% w(feature,1)
% X(instance,feature)
% y(instance,1)

r = X*w-y;

closeInd = abs(r) <= k;

f = (1/2)*sum(r(closeInd).^2) + k*sum(abs(r(~closeInd))) - (1/2)*sum(~closeInd)*k^2;
if nargout > 1
   g = X(closeInd,:)'*(X(closeInd,:)*w - y(closeInd)) + k*X(~closeInd,:)'*sign(r(~closeInd));
end

if nargout > 2
   H = X(closeInd,:)'*X(closeInd,:); 
end