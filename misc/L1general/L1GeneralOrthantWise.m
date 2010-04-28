function [w,fEvals] = L1GeneralOrthantWise(gradFunc,w,lambda,params,varargin)
%
% computes argmin_w: gradFunc(w,varargin) + sum lambda.*abs(w)
%
% Method used:
%   Orthant-Wise Regression
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
%
% Todo: take away partials for gradEvalTrace in line search if (d = 0)

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
    fprintf('%6s %6s %15s %15s %15s %15s\n','iter','fEvals','stepLen','f(w)','dirProjections','stepProjections');
end

% Adjust if initial w is 0
%w(w==0) = 1e-2;

p = length(w);
d = zeros(p,1);
xi = zeros(p,1);

global computeTrace
global gradEvalTrace
global errTrace
global wTrace

% Compute Evaluate Function
if order == 2
    [f,g,H] = pseudoGrad(w,gradFunc,lambda,varargin{:});
else
    [f,g] = pseudoGrad(w,gradFunc,lambda,varargin{:});
end
fEvals = 1;

i = 1;
while fEvals < maxIter
    w_old = w;
    f_old = f;
    xi_old = xi;
    
    % Check Optimality
    if sum(abs(g)) < optTol
        if verbose
            fprintf('Solution Found\n');
        end
        break;
    end
    
    if order == 2
        [L D perm] = mchol(H);
        d(perm) = -L' \ ((D.^-1).*(L \ g(perm)));
        
        if sum(abs(d)) > 1e5
            if verbose == 2
                fprintf('Step gone crazy, adjusting...\n');
            end
            [L D perm] = mchol(H,1);
            d = -L' \ ((D.^-1).*(L \ g(perm)));
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
        d = -B\g;
        g_prev = g;
        w_prev = w;
    end
    
    dirProjections = sum(sign(d)~=sign(-g));
    d(sign(d) ~= sign(-g)) = 0;
    
    xi = sign(w);
    xi(w==0) = sign(-g(w==0));
    
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
        t = min(1,1/sum(abs(g)));
    end
    
    % Line Search
    [t,w,f,g,LSfunEvals] = ArmijoBacktrack(w,t,d,f,f,g,gtd,1e-4,2,optTol,...
            max(verbose-1,0),0,1,@constrainedPseudoGrad,xi,gradFunc,lambda,varargin{:});
    fEvals = fEvals + LSfunEvals;
    
    % Evaluate gradients of non-free varables
    stepProjections = sum(sign(w) ~= xi);
    w(sign(w) ~= xi) = 0;
    if order == 2
        [f,g,H] = pseudoGrad(w,gradFunc,lambda,varargin{:});
    else
        [f,g] = pseudoGrad(w,gradFunc,lambda,varargin{:});
    end
    
    if computeTrace
        % We count the above evaluation, but do not count the last
        % evaluation done during the line search as a separate evaluation
        errTrace(1,end-1) = errTrace(1,end);
        errTrace = errTrace(1,1:end-1);
        wTrace(:,end-1) = wTrace(:,end);
        wTrace = wTrace(:,1:end-1);
        %gradEvalTrace(1,end-1) = gradEvalTrace(1,end);
        gradEvalTrace = gradEvalTrace(1,1:end-1);
    end
    
    
    % Update log
    if verbose
        fprintf('%6d %6d %15.5e %15.5e %15d %15d\n',i,fEvals,sum(abs(w-w_old)),f,dirProjections,stepProjections);
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


function [nll,g,H] = pseudoGrad(w,gradFunc,lambda,varargin)

p = length(w);

if nargout == 1
    [nll] = gradFunc(w,varargin{:});
elseif nargout == 2
    [nll,g] = gradFunc(w,varargin{:});
else
    [nll,g,H] = gradFunc(w,varargin{:});
end

global computeTrace;
if computeTrace
    updateTrace(w,nll+sum(lambda.*abs(w)),p);
end

nll = nll + sum(lambda.*abs(w));

if nargout > 1

    if 0 % Implementation as described in Andrew & Gao
        gradNeg = g + lambda.*sign(w);
        gradPos = gradNeg;
        gradNeg(w==0) = g(w==0) - lambda(w==0);
        gradPos(w==0) = g(w==0) + lambda(w==0);

        pseudoGrad = zeros(p,1);
        pseudoGrad(gradNeg > 0) = gradNeg(gradNeg > 0);
        pseudoGrad(gradPos < 0) = gradPos(gradPos < 0);
        g = pseudoGrad;
    else % Equivalent way of doing it
        g = getSlope(w,lambda,g,1e-4);
    end
end

end


function [nll,g,H] = constrainedPseudoGrad(w,xi,gradFunc,lambda,varargin)

w(sign(w) ~= xi) = 0;

if nargout == 1
    [nll] = pseudoGrad(w,gradFunc,lambda,varargin{:});
elseif nargout == 2
    [nll,g] = pseudoGrad(w,gradFunc,lambda,varargin{:});
else
    [nll,g,H] = pseudoGrad(w,gradFunc,lambda,varargin{:});
end

end
    

