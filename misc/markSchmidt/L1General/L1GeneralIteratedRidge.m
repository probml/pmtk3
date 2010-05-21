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

[verbose,maxIter,optTol,threshold,order,adjustStep,ABO] = ...
    myProcessOptions(params,'verbose',1,'maxIter',250,...
    'optTol',1e-6,'threshold',1e-4,'order',2,'adjustStep',1,'ABO',0);

% Start log
if verbose
    fprintf('%10s %10s %15s %15s %15s %5s\n','Iteration','FunEvals','Step Length','Function Val','Opt Cond','Non-Zero');
end

% Adjust if initial w is 0
w(w==0) = 1e-2;

p = length(w);

nonZero = zeros(p,1);

% Evaluate function
if order == 2
    [f,g,H] = wrapFunc(w,gradFunc,lambda,varargin{:});
else
    [f,g] = wrapFunc(w,gradFunc,lambda,varargin{:});
end
fEvals = 1;

    % Compute the non-zero elements of w and corresponding values of tau
    nonZero = (abs(w) >= threshold);

    % Check Optimality
    if sum(abs(g(nonZero))) < optTol
        if verbose
            fprintf('All Non-Zero Variables Satisfy optTol at Initial Point\n');
        end
        return;
    end

t = 1;
f_prev = f;
for i = 1:maxIter

    w_old = w;
    f_old = f;

    % Compute the step direction
    d = zeros(p,1);
    if order == 2
        d(nonZero) = solveNewton(g(nonZero),H(nonZero,nonZero));
    else
        if i == 1
            B = eye(p);
            w_prev = w;
            g_prev = g;
        else
            [B,g_prev,w_prev] = bfgsUpdate(B,w,w_prev,g,g_prev,i==2);
        end
        d(nonZero) = -B(nonZero,nonZero)\g(nonZero);
    end

    gtd = g'*d;
    if gtd > -optTol
        if verbose
            fprintf('Directional Derivative too small\n');
        end
        break;
    end

    if ABO
        if i > 1
           if t == t_init % Step size was accepted last time
               t = t_init*1.5;
           else % We had to backtrack last time
               t = t_init/1.5;
           end
        end
        t_init = t;
        fprintf('t = %f\n',t);
    else
        [t,f_prev] = initialStepLength(i,adjustStep,order,f,g,gtd,t,f_prev);
    end
    

    if order == 2
        [t,w,f,g,LSfunEvals,H] = ArmijoBacktrack(w,t,d,f,f,g,gtd,1e-4,2,optTol,1,0,0,@wrapFunc,gradFunc,lambda,varargin{:});
    else
        [t,w,f,g,LSfunEvals] = ArmijoBacktrack(w,t,d,f,f,g,gtd,1e-4,2,optTol,1,0,1,@wrapFunc,gradFunc,lambda,varargin{:});
    end
    fEvals = fEvals + LSfunEvals;

    % Update the log
    if verbose
        fprintf('%10d %10d %15.5e %15.5e %15.5e %5d\n',i,fEvals,t,f,sum(abs(g(abs(w)>=threshold))),sum(abs(w)>=threshold));
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

    if noProgress(t*d,f,f_old,optTol,verbose)
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
end