function [w,fEvals] = LassoUnconstrainedApx(X, y, lambda,varargin)
% This function computes the Least Squares parameters
% with a penalty on the L1-norm of the parameters
%
% Method used:
%   Uses a set of non-negative-squared variables to convert the problem
%   into an equivalent unconstrained problem (solved with fminunc)
%
% Mode:
%   0: use first-order method
%   1: use second-order method
%
[maxIter,verbose,optTol,zeroThreshold,mode] = process_options(varargin,'maxIter',...
    10000,'verbose',2,'optTol',1e-5,'zeroThreshold',1e-4,'mode',0);

[n p] = size(X);

% Start at the Ridge Regression solution
wFull = (X'*X + lambda*eye(p))\(X'*y);

options = optimset('Display','none','Diagnostics','off','GradObj','on',...
    'maxiter',maxIter,'LargeScale','off','MaxFunEvals',maxIter,'TolFun',optTol,...
    'TolX',optTol^2);

if mode == 1
   options.LargeScale = 'on';
   options.Hessian = 'on';
end

if verbose==2
    options.Display = 'iter';
elseif verbose
    options.Display = 'final';
end

gradFunc = @nonNegativeSquaredLasso;
X = [X -X];
w(1:p,1) = sqrt(wFull.*(wFull >= 0));
w(p+1:2*p,1) = sqrt(-wFull.*(wFull < 0));

[w fval exitflag output] = fminunc(gradFunc,w,options,X'*X,X'*y*2,y'*y,lambda);
fEvals = output.funcCount;

w = w(1:p).^2 - w(p+1:2*p).^2;

w(abs(w)<=zeroThreshold) = 0;
if verbose
    fprintf('Number of function evaluations: %d\n',fEvals);
end
end

function [f,g,H] = nonNegativeSquaredLasso(w,XX,Xy2,yy,lambda)

p = length(XX);

w2 = w.^2;

f = sum(w2.'*XX*w2 - w2.'*Xy2 + yy) + lambda*sum(w2);

if nargout > 1
g = 2*w.*(2*XX*w2 - Xy2) + 2*lambda*w;
end

if nargout > 2
   H =  4*diag(w)*(2*XX)*diag(w) + 2*diag(2*XX*w2 - Xy2) + 2*lambda*eye(p);
end
end