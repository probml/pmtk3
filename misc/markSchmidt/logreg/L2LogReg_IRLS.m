function [w,C] = L2LogReg_IRLS(X,y,lambda,w);
% Cannonical IRLS algorithm for 
%   L2-Penalized Logistic Regression
%   (this could oscillate for some problems)
%
% Returns maximum likelihood estimate w
%  and asymptotic covariance matrix C

[n,p] = size(X);

if nargin < 3
    lambda = 0;
end

if nargin < 4
    w = zeros(p,1);
end

if lambda == 0
    % Use a weak prior to make numerically stable
    % (could use lambda=0 if you added a stabilization method)
    lambda = 1e-4;
end

if isscalar(lambda)
    vInv = 2*lambda*eye(p);
else
    vInv = 2*lambda;
end

for i = 1:100
    w_old = w;
    Xw = X*w;
    yXw = y.*Xw;
    sig = 1./(1+exp(-yXw));
    Delta = sig.*(1-sig) + eps;
    z = Xw + (1-sig).*y./Delta;
    %w = (X'*diag(sparse(Delta))*X + 2*lambda*eye(p))\X'*diag(sparse(Delta))*z;
    Xd = X'*diag(sparse(Delta));
    R = chol(Xd*X + vInv);
    w = R\(R'\Xd*z);
    

    %fprintf('iter = %d, f = %.6f\n',i,sum(abs(w-w_old)));
    if sum(abs(w-w_old)) < 1e-9
        %fprintf('L2-LogReg: Done\n');
        break;
    end
end
if nargout > 1
    sig = 1./(1+exp(-yXw));
    C = inv(X'*diag(sig.*(1-sig))*X + vInv);
end