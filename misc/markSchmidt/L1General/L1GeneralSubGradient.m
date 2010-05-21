function [w,fEvals] = L1GeneralSubGradient(gradFunc,w,lambda,params,varargin)
%
% computes argmin_w: gradFunc(w,varargin) + sum lambda.*abs(w)
%
% Method used:
%   Sub-Gradient Descent on non-zero and zero but non-optimal variables
%
% Parameters
%   gradFunc - function of the form gradFunc(w,varargin{:})
%   w - initial guess
%   lambda - scale of L1 penalty on each variable
%       (set to 0 for unregularized variables)
%   options - user-modifiable parameters
%   varargin - parameters of gradFunc
%
% order:
%   1: First-order
%   2: Second-order

% Process input options
[verbose,maxIter,optTol,threshold,order,k,adjustStep] = ...
    myProcessOptions(params,'verbose',1,'maxIter',250,...
    'optTol',1e-6,'threshold',1e-4,'order',2,'k',0,'adjustStep',1);

% Start log
if verbose
    fprintf('%10s %10s %15s %15s %15s %5s\n','Iteration','FunEvals','Step Length','Function Val','Opt Cond','Non-Zero');
end

p = length(w);
free = zeros(p,1);

% Compute free variables
if order == 2
    [f,g,H] = subGradient(w,w,threshold,ones(p,1),gradFunc,lambda,varargin{:});
else
    [f,g] = subGradient(w,w,threshold,ones(p,1),gradFunc,lambda,varargin{:});
end
fEvals = 1;

    % Check Optimality
    if sum(abs(g)) < optTol
        if verbose
            fprintf('First-Order Optimality Satisfied at Initial Point\n');
        end
        return;
    end

i = 1;
t = 1;
f_prev = f;
while fEvals < maxIter
    w_old = w;

    f_old = f;
    
    if k > 0
        % Max-K Sub-Gradient
        [mx mxInd] = max(abs(g));
        free = abs(w) >= threshold; % Non-zero variables are free
        free(lambda==0) = 1; % Unpenalized variables are
        free(mxInd) = 1; % Variable with max sub-gradient is free
    else
        % Vanilla Sub-Gradient
        w(abs(w) < threshold) = 0;
        free = abs(g) > threshold;
    end

    if sum(free==1) == 0
        break;
    end
    
    % Compute step
    d = zeros(sum(free==1),1);
    if order == 2
        d = solveNewton(g(free==1),H(free==1,free==1));
    else
        if i == 1
            B = eye(p);
            w_prev = w;
            g_prev = g;
        else
            [B,g_prev,w_prev] = bfgsUpdate(B,w,w_prev,g,g_prev,i==2);
        end
        d = -B(free==1,free==1)\g(free==1);
    end

    gtd = g(free==1)'*d;
    if gtd > -optTol
        fprintf('Directional Derivative too small\n');
        break;
    end
    
    % Choose initial step length
    [t,f_prev] = initialStepLength(i,adjustStep,order,f,g,gtd,t,f_prev);
    
    % Line Search
    [t,w(free==1),f,g(free==1),LSfunEvals] = ArmijoBacktrack(w(free==1),t,d,f,f,g(free==1),gtd,1e-4,2,optTol,...
            max(verbose-1,0),0,1,@subGradient,w,threshold,free,gradFunc,lambda,varargin{:});
    fEvals = fEvals + LSfunEvals;
    
    % Evaluate gradients of non-free varables
    if order == 2
        [f,g,H] = subGradient(w,w,threshold,ones(p,1),gradFunc,lambda,varargin{:});
    else
        [f,g] = subGradient(w,w,threshold,ones(p,1),gradFunc,lambda,varargin{:});
    end
        
    % Update log
    if verbose
        fprintf('%10d %10d %15.5e %15.5e %15.5e %5d\n',i,fEvals,t,f,sum(abs(g)),sum(abs(w) > threshold));
    end

        % Check Optimality
    if sum(abs(g)) < optTol
        if verbose
            fprintf('Solution Found\n');
        end
        break;
    end
    
        if noProgress(t*d,f,f_old,optTol,verbose)
            break;
        end

    i = i +1;
end

if verbose && fEvals >= maxIter
    fprintf('Maximum Number of Iterations Exceeded\n');
end

end


function [nll,g,H] = subGradient(wSub,w,threshold,free,gradFunc,lambda,varargin)

% Make full w
w(free==1) = wSub;

if nargout == 1
    [nll] = gradFunc(w,varargin{:});
elseif nargout == 2
    [nll,g] = gradFunc(w,varargin{:});
else
    [nll,g,H] = gradFunc(w,varargin{:});
end

nll = nll + sum(lambda.*abs(w));

if nargout > 1
    slope = getSlope(w,lambda,g,threshold);
    g = slope(free==1);
end

if nargout > 2
    H = H(free==1,free==1);
end

end
