function [w,fEvals] = LassoUnconstrainedApx(X, y, lambda,varargin)
% This function computes the Least Squares parameters
% with a penalty on the L1-norm of the parameters
%
% Method used:
%   Unconstrained optimization using an approximation to |w|.
%   Implements 3 approximations to |w|, and 2 optimization strategies
%
% Mode:
%   0 - Approximate |w| with the sum of the integral of 2 sigmoids
%   (a generalization of Lee & Mangasarian, suggested by Glenn Fung)
%   1 - Approximate |w| with sqrt(w^2 + eps)
%   (suggested in Lee, Lee, Abeel, & Ng)
%   2 - Approximate |w| with |w| - mu*log(w.^2)
%   (a log-barrier function)
%
% Mode 2:
%   0 - Uses fminunc (Quasi-Newton) w/ fixed alpha
%   1 - Uses continuation method

[maxIter,verbose,optTol,zeroThreshold,mode,mode2] = process_options(varargin,'maxIter',10000,'verbose',2,'optTol',1e-5,'zeroThreshold',1e-4,'mode',0,'mode2',0);
[n p] = size(X);

% Start at the Ridge Regression solution
w = (X'*X + lambda*eye(p))\(X'*y);

options = optimset('Display','none','Diagnostics','off','GradObj','on','maxiter',maxIter,'LargeScale','off','MaxFunEvals',maxIter,'TolFun',optTol,'TolX',optTol^2);
if verbose==2
    options.Display = 'iter';
elseif verbose
    options.Display = 'final';
end

param = 1e-6; % Controls accuracy of approximations, closer to 0 is better (but harder to solve)
if mode == 0
    gradFunc = @smoothLasso;
elseif mode == 1
    gradFunc = @epsLasso;
elseif mode == 2
    gradFunc = @logBarrierLasso;
end

if mode2 == 0
    [w fval exitflag output] = fminunc(gradFunc,w,options,X'*X,X'*y*2,y'*y,lambda,param);
    fEvals = output.funcCount;
else
    [w fEvals] = LassoUNC_sub(gradFunc,w,X'*X,X'*y*2,y'*y,lambda,param,verbose,zeroThreshold,optTol,maxIter);
end

w(abs(w)<=zeroThreshold) = 0;
if verbose
fprintf('Number of function evaluations: %d\n',fEvals);
end

end


% Newton method with varying value of param
function [w,fEvals] = LassoUNC_sub(gradFunc,w,XX,Xy2,yy,t,param,verbose,zeroThreshold,optTol,maxIter)

if verbose==2
    fprintf('%10s %10s %15s %15s %15s\n','Iter','ObjEvals','Function Val','alpha','optCon(alpha)');
end
i = 0;
initParam = 1;
currParam = initParam; % If bad steps, increase this
nRestarts=0;
updateRate = 2/3;
[f,g,H] = gradFunc(w,XX,Xy2,yy,t,currParam);
fEvals = 1;
while currParam > param && i < maxIter
    i = i + 1;

    R = chol(H);
    d = -R \ (R' \ g);

    [f_td,g_td,H_td] = gradFunc(w+d,XX,Xy2,yy,t,currParam);
    fEvals = fEvals + 1;

    if f_td > f
        if verbose==2
            fprintf('Bad Newton Step, increasing alpha and decreasing update rate...\n');
        end
        nRestarts = nRestarts+1;
        initParam = initParam*2;
        currParam = initParam;
        updateRate = (1+updateRate)/2;
        [f,g,H] = gradFunc(w,XX,Xy2,yy,t,currParam);
        fEvals = fEvals + 1;
    else
        w = w + d;
        f = f_td;
        g = g_td;
        H = H_td;
        if verbose==2
            fprintf('%10d %10d %15.5e %15e %15.5e\n',i,fEvals,f,currParam,sum(abs(g(abs(w)>zeroThreshold))));
        end
        currParam = currParam*updateRate;
    end


    if sum(abs(g(abs(w)>zeroThreshold))) < optTol
        if verbose
        fprintf('Solution Found\n');
        end
        break;
    end
end
end

% Log-Barrier Approximation
function [f,g,H] = logBarrierLasso(w,XX,Xy2,yy,lambda,param)

mu = param;

f = sum(w'*XX*w - w'*Xy2 + yy) + lambda*sum(abs(w)) - mu*sum(log(w.^2));
if nargout > 1
    g = 2*(XX*w) - Xy2 + lambda*sign(w) - mu*2./w;
end
if nargout > 2
    H = 2*XX + diag(mu*2./(w.^2));
end
end


% Epsilon Approximation
function [f,g,H] = epsLasso(w,XX,Xy2,yy,lambda,param)

epsilon = param^2;
f = sum(w'*XX*w - w'*Xy2 + yy) + lambda*sum(sqrt(w.^2 + epsilon));
if nargout > 1
    g = 2*(XX*w) - Xy2 + lambda*w./(sqrt(w.^2+epsilon));
end
if nargout > 2
    H = 2*XX + diag(lambda*((w.^2+epsilon).^(-1/2) - (w.^2).*((w.^2+epsilon).^(-3/2))));
end
end

% Sum-Integral(Sigmoid) Approximation
function [f,g,H] = smoothLasso(w,XX,Xy2,yy,lambda,param)
% Returns the function value and gradient for the sigmoid lasso
% approximation

alpha = 1/param;
p = length(w);
XXw = XX*w;

lse = mylogsumexp([zeros(p,1) alpha*w]);
f = sum(w'*XXw - w'*Xy2 + yy) + lambda*sum(((1/alpha)*(lse+mylogsumexp([zeros(p,1) -alpha*w]))));

if nargout > 1
    g = 2*XXw - Xy2 + lambda*(1-2*exp(-lse));
end

if nargout > 2
    H = 2*XX + lambda*diag(exp(log(repmat(2,[p 1]))+log(repmat(alpha,[p 1]))+alpha*w-2*lse));
end
end


function lse = logsumexp(b)
B = max(b);
lse = log(sum(exp(b-B)))+B;
end