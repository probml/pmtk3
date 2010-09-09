function [nll,g,H] = SoftmaxLoss(w,X,y,k)
% w is nfeatures * nclasses 
% X is ncases * nfeatures
% y is ncases * 1
% k = nclasses
%
% This is like SoftmaxLoss2, except w is D*C not D*(C-1),
% since we don't assume the  weights for last class are fixed at 0

% This file is from pmtk3.googlecode.com



[n,p] = size(X);
w = reshape(w,[p k]);
%w(:,k) = zeros(p,1);

Z = sum(exp(X*w),2);
nll = -sum((sum(X.*w(:,y).',2) - log(Z)));

if nargout > 1
    g = zeros(p,k);
    for c = 1:k
        g(:,c) = -sum(X.*repmat((y==c) - exp(X*w(:,c))./Z,[1 p]));
    end
    g = reshape(g,[p*(k) 1]);
end

if nargout > 2
    H = zeros(p*(k));
    SM = exp(X*w(:,1:k))./repmat(Z,[1 k]);
    for c1 = 1:k
        for c2 = 1:k
            D = SM(:,c1).*((c1==c2)-SM(:,c2));
            H((p*(c1-1)+1):p*c1,(p*(c2-1)+1):p*c2) = X'*diag(sparse(D))*X;
        end
    end
end
