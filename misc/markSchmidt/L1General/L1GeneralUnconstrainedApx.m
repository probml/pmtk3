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
% options.alpha:
%   real number > 0: controls accuracy of approximation
%       (higher is better, but convergence will be slower)
% 
% options.updateRate:
%   real number > 1: the multiplicative update of alpha under mode2==2.
%       smaller values will decrease the chance of a bad step, but larger
%       values will decrease the number of iterations to convergence
%       if you don't have a bad step


[verbose,maxIter,optTol,mode,cont,alpha,order,adjustStep] = ...
    myProcessOptions(params,'verbose',1,'maxIter',250,...
    'optTol',1e-6,'mode',0,'cont',1,'alpha',1e5,'order',2,'adjustStep',1);

% Set parameters of fminunc
options = optimset('Display','none','MaxFunEvals',maxIter,...
    'MaxIter',maxIter,'TolX',optTol,'TolFun',optTol);

if verbose
    options.Display = 'iter';
end

p = length(w);

% Chose unconstrained approximation function
if mode == 0
    apxFunc = @sigmoidL1;
elseif mode == 1
    apxFunc = @epsilonL1;
elseif mode == 2
    apxFunc = @logBarrier0;
    w(w==0) = 1e-2;
elseif mode == 3
    apxFunc = @logBarrierNonNeg;
    w = [w.*(w >= 0);w.*(w<=0)];
    w(w==0) = 1e-2;
    adjustStep = 0; % Log-Barrier works better if you always try step length of 1 first
    params.update2 = 2;
end

% Optimize
if cont
    % Continuation method
    [w output.funcCount] = L1GeneralUnconstrainedApx_sub(apxFunc,w,params,order,gradFunc,lambda,varargin{:});
else
    if order == 2
        options.Method = 'newton';
        options.LS_saveHessianComp = 0;
    else
        options.Method = 'qnewton';
        options.qnUpdate = 0;
    end

    if adjustStep == 1
        options.LS_init = 3;
    end
    
    [w fval exitflag output] = minFunc(apxFunc,w,options,alpha,gradFunc,lambda,varargin{:});

end
fEvals = output.funcCount;

if mode == 3
    w = w(1:p)-w(p+1:end);
end
