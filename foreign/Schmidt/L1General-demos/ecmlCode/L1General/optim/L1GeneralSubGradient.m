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
[verbose,maxIter,optTol,threshold,alpha,order] = ...
    myProcessOptions(params,'verbose',1,'maxIter',250,...
    'optTol',1e-6,'threshold',1e-4,'alpha',5e4,'order',2);

% Some loss functions also use alpha as a parameter
if alphaUsedInLoss(gradFunc)
    varargin = {alpha,varargin{:}};
end


% Start log
if verbose
    fprintf('%6s %6s %15s %15s %5s\n','iter','fEvals','stepLen','f(w)','free');
end

% Adjust if initial w is 0
w(w==0) = 1e-2;

% Initialize
p = length(w);
if order == 2
    [f,g,H] = subGrad(w,lambda,threshold,gradFunc,varargin{:});
else
        [f,g] = subGrad(w,lambda,threshold,gradFunc,varargin{:});
end
fEvals = 1;

i = 1;
while fEvals < maxIter
    w_old = w;
    f_old = f;
    % Compute free variables
    w(abs(w) < threshold) = 0;
    free = ones(p,1);
    free(w==0 & lambda ~= 0 & abs(g)-lambda < lambda+optTol) = 0;

    % Check Optimality
    if sum(abs(g(free==1))) < optTol
        if verbose
            fprintf('Solution Found\n');
        end
        break;
    end
    if sum(free==1) == 0
        break;
    end
    
    % Compute step
    d = zeros(p,1);
    if order == 2
        
        [L D perm] = mchol(H(free==1,free==1));
        dtemp = zeros(sum(free==1),1);
        gtemp = g(free==1);
        dtemp(perm) = -L' \ ((D.^-1).*(L \ gtemp(perm)));
        d(free==1) = dtemp;
        
        if sum(abs(d)) > 1e5
            if verbose == 2
                fprintf('Step gone crazy, adjusting...\n');
            end
            [L D perm] = mchol(H(free==1,free==1),1);
            dtemp = zeros(sum(free==1),1);
            gtemp = g(free==1);
            dtemp(perm) = -L' \ ((D.^-1).*(L \ gtemp(perm)));
            d(free==1) = dtemp;
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
        d(free==1) = -B(free==1,free==1)\g(free==1);
        g_prev = g;
        w_prev = w;
    end

    gtd = g'*d;
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
    
    if order == 2
        [t,w,f,g,LSfunEvals,H] = ArmijoBacktrack(w,t,d,f,f,g,gtd,1e-4,2,optTol,...
            max(verbose-1,0),0,0,@subGrad,lambda,threshold,gradFunc,varargin{:});
    else
        [t,w,f,g,LSfunEvals] = ArmijoBacktrack(w,t,d,f,f,g,gtd,1e-4,2,optTol,...
            max(verbose-1,0),0,1,@subGrad,lambda,threshold,gradFunc,varargin{:});
    end
    fEvals = fEvals + LSfunEvals;

    % Update log
    if verbose
        fprintf('%6d %6d %15.5e %15.5e %5d\n',i,fEvals,sum(abs(w-w_old)),f,sum(free));
    end

    % Check Convergence Criteria
    if 1
    if sum(abs(t*d)) < optTol
        fprintf('Step too small\n');
        break;
    end
    else
        
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

function [f,g,H] = subGrad(w,lambda,threshold,gradFunc,varargin)
if nargout == 1
    f = gradFunc(w,varargin{:}) + sum(lambda.*abs(w));
end
if nargout == 2
    [f,g] = gradFunc(w,varargin{:});
end
if nargout == 3
    [f,g,H] = gradFunc(w,varargin{:});
end

if nargout > 1
    f = f + sum(lambda.*abs(w));
    g = getSlope(w,lambda,g,threshold);
end

global computeTrace;
% Update trace
if computeTrace
    updateTrace(w,f);
end
end
