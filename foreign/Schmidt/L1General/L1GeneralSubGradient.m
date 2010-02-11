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
[verbose,maxIter,optTol,threshold,alpha,order,k] = ...
    myProcessOptions(params,'verbose',1,'maxIter',250,...
    'optTol',1e-6,'threshold',1e-4,'alpha',5e4,'order',2,'k',0);

% Some loss functions also use alpha as a parameter
if alphaUsedInLoss(gradFunc)
    varargin = {alpha,varargin{:}};
end

% Start log
if verbose
    fprintf('%6s %6s %15s %15s %5s\n','iter','fEvals','stepLen','f(w)','free');
end

p = length(w);

global computeTrace
global gradEvalTrace
global errTrace
global wTrace
free = zeros(p,1);

% Compute free variables
if order == 2
    [f,g,H] = subGradient(w,w,threshold,ones(p,1),gradFunc,lambda,varargin{:});
else
    [f,g] = subGradient(w,w,threshold,ones(p,1),gradFunc,lambda,varargin{:});
end
fEvals = 1;

i = 1;
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

    % Check Optimality
    if sum(abs(g)) < optTol
        if verbose
            fprintf('Solution Found\n');
        end
        break;
    end
    if sum(free==1) == 0
        break;
    end
    
    % Compute step
    d = zeros(sum(free==1),1);
    if order == 2
        
        [L D perm] = mchol(H(free==1,free==1));
        dtemp = zeros(sum(free==1),1);
        gtemp = g(free==1);
        d(perm) = -L' \ ((D.^-1).*(L \ gtemp(perm)));
        
        if sum(abs(d)) > 1e5
            if verbose == 2
                fprintf('Step gone crazy, adjusting...\n');
            end
            [L D perm] = mchol(H(free==1,free==1),1);
            dtemp = zeros(sum(free==1),1);
            gtemp = g(free==1);
            d(perm) = -L' \ ((D.^-1).*(L \ gtemp(perm)));
        end
    else
        if i == 1
            B = eye(p);
        else
            y = g-g_prev;
            s = w-w_prev;
            
            ys = y'*s;
            
            if i == 2
                if ys > 1e-10
                    B = ((y'*y)/(y'*s))*eye(p);
                end
            end
            if ys > 1e-10
                B = B + (y*y')/(y'*s) - (B*s*s'*B)/(s'*B*s);
            else
                fprintf('Skipping Update\n');
            end
        end
        d = -B(free==1,free==1)\g(free==1);
        g_prev = g;
        w_prev = w;
    end

    gtd = g(free==1)'*d;
    if gtd > -optTol
        fprintf('Directional Derivative too small\n');
        break;
    end
    
    % Try Newton step
    t = 1;
    
    % Adjust if step is too large
    if sum(abs(d)) > 1e5
        fprintf('Step too large\n');
        sum(abs(d))
        t = 1e5/sum(abs(d));
    end
    
    % Adjust on first iteration
    if order == 1 && i == 1
        t = min(1,1/sum(abs(g(free==1))));
    end
    
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
    
    if computeTrace
        % We need to take away partials for free variable gradients
        % computed during line search
        % (no line search on 1st iteration)
        %fprintf('Taking away %d for free variables\n',sum(free==1));
        gradEvalTrace(1,end) = gradEvalTrace(1,end) - sum(free==1);
        
        % We count the above evaluation, but do not count the last
        % evaluation done during the line search as a separate evaluation
        errTrace(1,end-1) = errTrace(1,end);
        errTrace = errTrace(1,1:end-1);
        wTrace(:,end-1) = wTrace(:,end);
        wTrace = wTrace(:,1:end-1);
        gradEvalTrace(1,end-1) = gradEvalTrace(1,end);
        gradEvalTrace = gradEvalTrace(1,1:end-1);
    end
    
    
    % Update log
    if verbose
        fprintf('%6d %6d %15.5e %15.5e %5d\n',i,fEvals,sum(abs(w-w_old)),f,sum(free));
    end

    % Check Convergence Criteria
    if sum(abs(t*d)) < optTol
        fprintf('Step too small\n');
        break;
    end
    
    if abs(f-f_old) < optTol
        fprintf('Function not changing\n');
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

global computeTrace;
if computeTrace
    updateTrace(w,nll+sum(lambda.*abs(w)),sum(free));
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
