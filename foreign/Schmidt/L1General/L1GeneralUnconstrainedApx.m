function [w,fEvals] = L1GeneralUnconstrainedApx(gradFunc,w,lambda,params,varargin)
%
% computes argmin_w: gradFunc(w,varargin) + sum lambda.*abs(w)
%
% Method used:
%   Unconstrained optimization using an approximation to |w|.
%   Implements 4 approximations to |w|, and 2 optimization strategies
%
% Parameters
%   gradFunc - function of the form gradFunc(w,varargin{:})
%   w - initial guess
%   lambda - scale of L1 penalty on each variable
%       (set to 0 for unregularized variables)
%   options - user-modifiable parameters
%   varargin - parameters of gradFunc
%
% Method specific options:
%
% options.mode:
%   0 - Approximate |w| with the sum of the integral of 2 sigmoids
%   (a generalization of Lee & Mangasarian, suggested by Glenn Fung)
%   1 - Approximate |w| with sqrt(w^2 + eps)
%   (suggested in Lee, Lee, Abeel, & Ng)
%   2 - Approximate |w| with |w| - mu*log(w.^2)
%   (a log-barrier function)
%   3 - Use Non-Negative variables and log-barrier against variables
%       becoming negative
%
% options.solver:
%   0  - fminunc, bfgs
%   1  - fminunc, newton TR
%   2 - call 'method' in minFunc with 'LS' line search
%   -1 - annealed first-order method
%   -2 - annealed second-order method
%
% options.alpha:
%   real number > 0: controls accuracy of approximation
%       (higher is better, but convergence will be slower)
% 
% options.updateRate:
%   real number > 1: the multiplicative update of alpha under mode2==2.
%       smaller values will decrease the chance of a bad step, but larger
%       values will decrease the number of iterations to convergence
%       if you don't have a bad step
%
%


[verbose,maxIter,mode,solver,alpha,method,LS,HM,LSI] = ...
    myProcessOptions(params,'verbose',1,'maxIter',250,...
    'mode',0,'solver',2,'alpha',5e4,...
    'method','newton','LS',2,'HM',2,'LSI',2);

% Set parameters of fminunc
options = optimset('Display','none','MaxFunEvals',maxIter,'LargeScale','off',...
    'gradObj','on','DerivativeCheck','off','MaxIter',maxIter,'TolX',1e-6,'TolFun',1e-6);
if verbose
    options.Display = 'iter';
end

p = length(w);

% Chose unconstrained approximation function
if mode == 0
    apxFunc = @sigmoidL1;
elseif mode == 1
    apxFunc = @epsilonL1;
    alpha = (alpha^2);
elseif mode == 2
    apxFunc = @logBarrier0;
    w(w==0) = 1e-2;
    if solver == 0 || solver == 1
        fprintf('Log-Barrier dont work w/ fminunc\n');
        solver = 3;
        mfLS = 2;
    end
elseif mode == 3
    apxFunc = @logBarrierNonNeg;
    w = [w.*(w >= 0);w.*(w<=0)];
    w(w==0) = 1e-2;
    if solver == 0 || solver == 1
        fprintf('Log-Barrier dont work w/ fminunc\n');
        solver = 3;
        mfLS = 2;
    end
end

% Some loss functions also use alpha as a parameter
if solver >= 0 && alphaUsedInLoss(gradFunc)
    varargin = {alpha,varargin{:}};
end

% Optimize
if solver == 0
    % BFGS
    [w fval exitflag output] = fminunc(apxFunc,w,options,alpha,gradFunc,lambda,varargin{:});
elseif solver == 1;
    options.LargeScale = 'on';
    options.Hessian = 'on';
        [w fval exitflag output] = fminunc(apxFunc,w,options,alpha,gradFunc,lambda,varargin{:});
elseif solver < 0
    % Continuation method
    [w output.funcCount] = L1GeneralUnconstrainedApx_sub(apxFunc,w,params,-solver,gradFunc,lambda,varargin{:});
else
    if verbose == 2
        options.Display = 'full';
    elseif verbose == 1
        options.Display = 'iter';
    else
        options.Display = 'none';
    end
    options.Method = method;
    options.LS_saveHessianComp = 0;
    options.LS = LS;
    
    options.LS_init = LSI;
    options.HessianModify = HM;
    
    [w fval exitflag output] = minFunc(apxFunc,w,options,alpha,gradFunc,lambda,varargin{:});

end
fEvals = output.funcCount;

if mode == 3
    w = w(1:p)-w(p+1:end);
end
