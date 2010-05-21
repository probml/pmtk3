function [f,g] = SSVMMultiLoss(w,X,y,k)
% w(feature*class,1)
% X(instance,feature)
% y(instance,1)
%
% f = sum_k ( max(0, 1 + <w_k,x> - <w_y,x> ) )

[n,p] = size(X);
w = reshape(w,[p k]);

f = 0;
g = zeros(p,k);
for i = 1:n
    for c = 1:k
        if c ~= y(i)
            err = 1 + X(i,:)*(w(:,c) - w(:,y(i)));
            if err > 0
                f = f + err^2;
                
                if nargout > 1
                    g(:,c) = g(:,c) + 2*X(i,:)'*err;
                    g(:,y(i)) = g(:,y(i)) - 2*X(i,:)'*err;
                end
            end
        end
    end
end
g = g(:);