function [w,fEvals] = L1GeneralGrafting(gradFunc,w,lambda,params,varargin)
%
% computes argmin_w: gradFunc(w,varargin) + sum lambda.*abs(w)
%
% Method used:
%   Grafting
%
% Parameters
%   gradFunc - function of the form gradFunc(w,varargin{:})
%   w - initial guess
%   lambda - scale of L1 penalty on each variable
%       (set to 0 for unregularized variables)
%   options - user-modifiable parameters
%   varargin - parameters of gradFunc

% Process input options
[verbose,maxIter,optTol,threshold,order,adjustStep] = ...
    myProcessOptions(params,'verbose',1,'maxIter',250,...
    'optTol',1e-6,'threshold',1e-4,...
    'order',2,'adjustStep',1);
options = optimset('Display','off','MaxFunEvals',maxIter,...
    'maxiter',maxIter,'TolFUN',optTol,'TolX',optTol);

if order == 2
    options.Method = 'newton';
    options.LS_saveHessianComp = 0;
elseif order == 1
    options.Method = 'qnewton';
    options.qnUpdate = 0;
end

if adjustStep == 1
    options.LS_init = 2;
end

% Initialize
p = length(w);
fEvals = 0;
oldmaxpos = -1;
oldmaxpos2= -1;
free = abs(w) > 1e-4;
free(lambda==0) = 1; % Un-penalized variables are always free

% Optimize un-penalized variables first
if sum(lambda==0) ~= 0
    if verbose
        fprintf('Optimizing un-penalized variables\n');
    end
    [w(free==1) fval exitflag output] = minFunc(@subGradient,w(free==1),options,threshold,free,gradFunc,lambda,varargin{:});
    fEvals = fEvals + output.funcCount;
end

% Start log
if verbose
    fprintf('%10s %10s %15s %15s %15s %5s\n','Iteration','FunEvals','Norm(Step)','Function Val','Opt Cond','Non-Zero');

end

for i = 1:maxIter

    % Compute the sub-gradient
    % (we give this evaluation for free, since the subroutine recomputes it)

    [f,g] = gradFunc(w,varargin{:});

    fval = f+sum(lambda.*abs(w));
    slope = getSlope(w,lambda,g,threshold);

    % Check optimality
    nonZero = abs(w) >= threshold;
    atZero = abs(w) < threshold;
    if sum(abs(slope(nonZero))) < optTol && ...
            all(abs(g(atZero)) < lambda(atZero)+optTol)
        if verbose
            fprintf('Solution Found\n');
        end
        break;
    end

    % find max magnitude zero-valued variable and add to free variables
    [max_viol max_violPos] = max(abs(slope));
    free(max_violPos) = 1;

    if oldmaxpos == max_violPos && oldmaxpos == oldmaxpos2
        if verbose
            fprintf('Cant Introduce Anything, Terminating\n');
        end
        break;
    end
    oldmaxpos2=oldmaxpos;
    oldmaxpos=max_violPos;

    % solve with all free variables
    old_fval = fval;
    w_old = w;
    [w(free==1) fval exitflag output] = minFunc(@subGradient,w(free==1),options,threshold,free,gradFunc,lambda,varargin{:});
    fEvals = fEvals + output.funcCount;

    % check to see if the function value changed
    if abs(fval-old_fval) < optTol
        if verbose
            fprintf('Function Value not Decreasing\n');
        end
        break;
    end

    % update the free variable set
    free_old = free;
    free = abs(w) >= threshold;
    free(lambda==0) = 1;
    w(free==0) = 0;

    % update the log
    if verbose
        [f,g] = gradFunc(w,varargin{:});
        fval = f+sum(lambda.*abs(w));
        slope = getSlope(w,lambda,g,threshold);
        nonZero = abs(w) >= threshold;;
        fprintf('%10d %10d %15.5e %15.5e %15.5e %5d\n',i,fEvals,sum(abs(w-w_old)),fval,sum(abs(slope)),sum(abs(w) > threshold));
    end

    if fEvals > maxIter
        break;
    end
end


end


function [nll,g,H] = subGradient(wSub,threshold,free,gradFunc,lambda,varargin)

% Make full w
w = zeros(size(free));
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