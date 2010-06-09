function [w,fEvals] = L1GeneralProjectedSubGradientBB(gradFunc,w,lambda,params,varargin)
%
% computes argmin_w: gradFunc(w,varargin) + sum lambda.*abs(w)
%
% Method used:
%   Projected sub-gradient descent with Barzilai-Borwein step length
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
%   (ignored)
%
% Todo: take away partials for gradEvalTrace in line search if (d = 0)

% Process input options
[verbose,maxIter,optTol,threshold,adjustStep,memory,bbType] = ...
    myProcessOptions(params,'verbose',1,'maxIter',250,...
    'optTol',1e-6,'threshold',1e-4,'adjustStep',0,'memory',10,'bbType',1);

% Start log
if verbose
    fprintf('%10s %10s %15s %15s %15s %8s %5s\n','Iteration','FunEvals','Step Length','Function Val','Opt Cond','Non-Zero','stpPr');
end

p = length(w);
d = zeros(p,1);
xi = zeros(p,1);

% Compute Evaluate Function
    [f,g] = pseudoGrad(w,gradFunc,lambda,varargin{:});
fEvals = 1;

    % Check Optimality
    if sum(abs(g)) < optTol
        if verbose
            fprintf('First-Order Optimality Satisfied at Initial Point\n');
        end
        return;
    end

t = 1;
f_prev = f;
i = 1;
while fEvals < maxIter
    w_old = w;
    f_old = f;
    xi_old = xi;
    
    % Compute step direction
    if i == 1
        alpha = 1;
    else
        y = g-myG_old;
        s = w-myW_old;
        if bbType == 0
            alpha = (s'*y)/(y'*y);
        else
            alpha = (s'*s)/(s'*y);
        end
        if alpha <= 1e-10 || alpha > 1e10
            alpha = 1;
        end
    end
    d = -alpha*g;
    myG_old = g;
    myW_old = w;
        
    % Compute Orthant
    xi = sign(w);
    xi(w==0) = sign(-g(w==0));
    
    gtd = g'*d;
    if gtd > -optTol
        fprintf('Directional Derivative too small\n');
        break;
    end
    
    [t,f_prev] = initialStepLength(i,adjustStep,1,f,g,gtd,t,f_prev);
    
    if memory == 1
        funRef = f;
    else
        if i == 1
            old_fvals = repmat(-inf,[memory 1]);
        end

        if i <= memory
            old_fvals(i) = f;
        else
            old_fvals = [old_fvals(2:end);f];
        end
        funRef = max(old_fvals);
    end
    
    % Line Search
    [t,w,f,g,LSfunEvals] = ArmijoBacktrack(w,t,d,f,funRef,g,gtd,1e-4,2,optTol,...
            max(verbose-1,0),0,1,@constrainedPseudoGrad,xi,gradFunc,lambda,varargin{:});
    fEvals = fEvals + LSfunEvals;
    
    % Evaluate gradients of non-free varables
    stepProjections = sum(sign(w) ~= xi);
    w(sign(w) ~= xi) = 0;
    
    % Update log
    if verbose
        fprintf('%10d %10d %15.5e %15.5e %15.5e %8d %5d\n',i,fEvals,t,f,sum(abs(g)),sum(abs(w)>=threshold),stepProjections);
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


function [nll,g,H] = pseudoGrad(w,gradFunc,lambda,varargin)

p = length(w);

if nargout == 1
    [nll] = gradFunc(w,varargin{:});
elseif nargout == 2
    [nll,g] = gradFunc(w,varargin{:});
else
    [nll,g,H] = gradFunc(w,varargin{:});
end

nll = nll + sum(lambda.*abs(w));

if nargout > 1
        g = getSlope(w,lambda,g,1e-4);
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
    

