function [w,fEvals] = L1GeneralIteratedRidge(gradFunc,w,lambda,params,varargin)
%
% computes argmin_w: gradFunc(w,varargin) + sum lambda.*abs(w)
%
% Method used:
%   Iterated L2-Penalized Optimization using the approximation
%   |w| =~ norm(w,2)/norm(w_old,1)
%
% Parameters
%   gradFunc - function of the form gradFunc(w,varargin{:})
%   w - initial guess
%   lambda - scale of L1 penalty on each variable
%       (set to 0 for unregularized variables)
%   options - user-modifiable parameters
%   varargin - parameters of gradFunc
%
% Order:
%   1 - First-Order
%   2 - Second-Order

[verbose,maxIter,optTol,threshold,alpha,order] = ...
    myProcessOptions(params,'verbose',1,'maxIter',250,...
    'optTol',1e-6,'threshold',1e-4,'alpha',5e4,'order',2);

% Start log
if verbose
    fprintf('%5s %5s %15s %15s %15s %5s\n','iter','fEvals','n(w)','n(step)','f(w)','free');
end

% Some loss functions also use alpha as a parameter
if alphaUsedInLoss(gradFunc)
    varargin = {alpha,varargin{:}};
end

% Adjust if initial w is 0
w(w==0) = 1e-2;

p = length(w);

global computeTrace
global gradEvalTrace
global nonZero
nonZero = zeros(p,1);

% Evaluate function
if order == 2
    [f,g,H] = wrapFunc(w,gradFunc,lambda,varargin{:});
else
    [f,g] = wrapFunc(w,gradFunc,lambda,varargin{:});
end
fEvals = 1;

for i = 1:maxIter

    w_old = w;
    f_old = f;
    
    if computeTrace
        % We need to add partials for non-free variables here
        % (on first iter, free = 0)
        %fprintf('Adding %d for non-free variables\n',sum(nonZero==0));
        gradEvalTrace(1,end) = gradEvalTrace(1,end) + sum(nonZero==0);
    end

    % Compute the non-zero elements of w and corresponding values of tau
    nonZero = (abs(w) >= threshold);

    % Check Optimality
    if sum(abs(g(nonZero))) < optTol
        if verbose
            fprintf('Solution Found\n');
        end
        break;
    end
    if sum(nonZero) == 0
        break;
    end

    % Compute the step direction
    d = zeros(p,1);
    if order == 2
        [L D perm] = mchol(H(nonZero,nonZero));
        dtemp = zeros(sum(nonZero),1);
        gtemp = g(nonZero);
        dtemp(perm) = -L' \ ((D.^-1).*(L \ gtemp(perm)));
        d(nonZero) = dtemp;

        while sum(abs(d)) > 1e5
            if verbose
                fprintf('Step gone crazy, adjusting...\n');
            end
            [L D perm] = mchol(H(nonZero,nonZero),1);
            dtemp = zeros(sum(nonZero),1);
            gtemp = g(nonZero);
            dtemp(perm) = -L' \ ((D.^-1).*(L \ gtemp(perm)));
            d(nonZero) = dtemp;
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
        d(nonZero) = -B(nonZero,nonZero)\g(nonZero);
        g_prev = g;
        w_prev = w;
    end

    if g'*d > -optTol
        if verbose
            fprintf('Directional Derivative too small\n');
        end
        break;
    end

    % Compute the step length
    t = 1;

    % Adjust if step is too large
    if sum(abs(d)) > 1e5
        fprintf('Step too large\n');
        t = 1e5/sum(abs(d));
    end

    % Adjust on first iteration
    if order == 1 && i == 1
        t = min(1,1/sum(abs(g(nonZero))));
    end

    if order == 2
        [t,w,f,g,LSfunEvals,H] = ArmijoBacktrack(w,t,d,f,f,g,g'*d,1e-4,2,optTol,1,0,0,@wrapFunc,gradFunc,lambda,varargin{:});
    else
        [t,w,f,g,LSfunEvals] = ArmijoBacktrack(w,t,d,f,f,g,g'*d,1e-4,2,optTol,1,0,1,@wrapFunc,gradFunc,lambda,varargin{:});
    end
    fEvals = fEvals + LSfunEvals;

    % Update the log
    if verbose
        fprintf('%5d %5d %15.5e %15.5e %15.5e %5d\n',i,fEvals,sum(abs(w)),sum(abs(w-w_old)),f,sum(abs(w)>=threshold));
    end

    sumabs = sum(abs(w-w_old));
    if sumabs < optTol
        if verbose
            fprintf('Step Size below tolerance\n');
        end
        break;
    elseif abs(f-f_old) < optTol
        if verbose
            fprintf('Function change below tolerance\n');
        end
        break;
    elseif sumabs > 1e100
        if verbose
            fprintf('Diverging from Solution\n');
        end
        break;
    elseif fEvals > maxIter
        fprintf('Maximum Number of Iterations Exceeded\n');
        break;
    end

end


w(abs(w) <= threshold) = 0;

end

function [f,g,H] = wrapFunc(w,gradFunc,lambda,varargin)
if nargout > 2
    [f,g,H] = gradFunc(w,varargin{:});
else
    [f,g] = gradFunc(w,varargin{:});
end


tau = abs(w);
tau(tau==0) = inf;
f = f+sum(lambda.*abs(w));
g = g+lambda.*w./tau;
if nargout > 2
    H = H+diag(lambda./tau);
end

global computeTrace;
if computeTrace
    global nonZero
    updateTrace(w,f,sum(nonZero==1));
end
end