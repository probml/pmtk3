function [nll,g,H] = SoftmaxLossDummy(w,X,ydummy,weights)
% w is nfeatures * nclasses 
% X is ncases * nfeatures
% ydummy is ncases * nclasses, y(i,c)=1 if in class c
%
% This is just like SoftmaxLoss except
% y is dummy encoded. This allows for soft outputs.
% We do not assume any columns of W are clamped to 0.

% This file is from pmtk3.googlecode.com

k = size(ydummy,2);
[n,p] = size(X);
if nargin < 4, weights = ones(n,1); end
w = reshape(w,[p k]);
%w(:,k) = zeros(p,1);

logpred = softmaxLog(X, w); % n,c
ll = sum(logpred .* ydummy, 2);
nll = -sum(weights .* ll);
%Z = sum(exp(X*w),2);
%nll = -sum((sum(X.*w(:,y).',2) - log(Z)));

Xw = X .* repmat(colvec(weights), 1, p);
if nargout > 1
  mu = exp(logpred);
    g = zeros(p,k);
    for c = 1:k
        %g(:,c) = -sum(X.*repmat((y==c) - exp(X*w(:,c))./Z,[1 p]));
        %g(:,c) = -sum(X.*repmat(ydummy(:,c) - mu(:,c),[1 p]));
        g(:,c) = -sum(Xw.*repmat(ydummy(:,c) - mu(:,c),[1 p]));
    end
    g = reshape(g,[p*(k) 1]);
end

if nargout > 2
    H = zeros(p*(k));
    SM = mu; % exp(X*w(:,1:k))./repmat(Z,[1 k]);
    for c1 = 1:k
        for c2 = 1:k
            D = SM(:,c1).*((c1==c2)-SM(:,c2));
            %H((p*(c1-1)+1):p*c1,(p*(c2-1)+1):p*c2) = X'*diag(sparse(D))*X;
            H((p*(c1-1)+1):p*c1,(p*(c2-1)+1):p*c2) = X'*diag(sparse(D))*Xw;
        end
    end
end
