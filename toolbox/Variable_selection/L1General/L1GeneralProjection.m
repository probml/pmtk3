function [w,fEvals] = L1GeneralProjection(gradFunc,w,lambda,params,varargin)
%
% computes argmin_w: gradFunc(w,varargin) + sum lambda.*abs(w)
%
% Method used:
%   Two-Metric Projection method w/ non-negative variables
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
%   -1: First-order (limited-memory)
%   1: First-order (full-memory)
%   2: Second-order

if nargin < 4
    params = [];
end

% Process input options
[verbose,maxIter,optTol,threshold,order,corrections,adjustStep] = ...
    myProcessOptions(params,'verbose',1,'maxIter',250,...
    'optTol',1e-6,'threshold',1e-4,'order',2,'corrections',100,'adjustStep',0);

% Start log
if verbose
    fprintf('%10s %10s %15s %15s %15s %5s\n','Iteration','FunEvals','Step Length','Function Val','Opt Cond','Non-Zero');
end

% Initialize
w = [w.*(w >= 0);-w.*(w<=0)];
p = length(w);

if order >= 2
    [f,g,H] = nonNegGrad(w,lambda,gradFunc,varargin{:});
else
    [f,g] = nonNegGrad(w,lambda,gradFunc,varargin{:});
end
fEvals = 1;

% Compute free variables
w(abs(w) < threshold) = 0;
free = ones(p,1);
free(w==0 & g >= 0) = 0;

if sum(abs(g(free==1))) < optTol
    if verbose
        fprintf('Initial Point satisfies optTol\n');
    end
    w = w(1:length(w)/2)-w(length(w)/2 + 1:end);
    return;
end
if sum(free==1) == 0
    w = w(1:length(w)/2)-w(length(w)/2 + 1:end);
    return;
end

% Backtrack along projection arc
pArc = 1;

t = 1;
f_prev = f;
i = 1;
Hdiag = 1;
while fEvals < maxIter
    
    w_old = w;
    f_old = f;

    % Compute step
    d = zeros(p,1);
    if order == 2

        d(free==1) = solveNewton(g(free==1),H(free==1,free==1),1,verbose);
    elseif order == 1 % BFGS
        if i == 1
            B = eye(p);
            g_prev = g;
            w_prev = w;
        else
            [B,g_prev,w_prev] = bfgsUpdate(B,w,w_prev,g,g_prev,i==2);
        end
        d(free==1) = -B(free==1,free==1)\g(free==1);
    elseif order == -1 % L-BFGS
        if i == 1
            d(free==1) = -g(free==1);
            old_dirs = zeros(p,0);
            old_stps = zeros(p,0);
            Hdiag = 1;
        else
            y = g-g_prev;
            s = w-w_prev;

            numCorrections = size(old_dirs,2);
            if numCorrections < corrections
                % Full Update
                old_dirs(:,numCorrections+1) = s;
                old_stps(:,numCorrections+1) = y;
            else
                % Limited-Memory Update
                old_dirs = [old_dirs(:,2:corrections) s];
                old_stps = [old_stps(:,2:corrections) y];
            end

            % Update scale of initial Hessian approximation
            ys = y'*s;
            if ys > 1e-10
                Hdiag = ys/(y'*y);
            end
            
            % Find updates where curvature condition was satisfied
            curvSat = sum(old_dirs(free==1,:).*old_stps(free==1,:)) > 1e-10;

            % Compute descent direction
            d(free==1) = lbfgsC(-g(free==1),old_dirs(free==1,curvSat),old_stps(free==1,curvSat),Hdiag);

        end
        g_prev = g;
        w_prev = w;
    end

    gtd = g'*d;
    
    if gtd > -optTol
        if verbose
            fprintf('Directional Derivative too small\n');
        end
        break;
    end

    if pArc == 0
        d = max(w + d,0)-w;
    end

    [t,f_prev] = initialStepLength(i,adjustStep,order,f,g,gtd,t,f_prev);


    % Line Search
    if order >= 2
        [t,w,f,g,LSfunEvals,H] = ArmijoBacktrack(w,t,d,f,f,g,gtd,1e-4,2,optTol,...
            max(verbose-1,0),0,0,@projNonNegGrad,lambda,gradFunc,varargin{:});
    else
        [t,w,f,g,LSfunEvals] = ArmijoBacktrack(w,t,d,f,f,g,gtd,1e-4,2,optTol,...
            max(verbose-1,0),0,1,@projNonNegGrad,lambda,gradFunc,varargin{:});
    end
    fEvals = fEvals + LSfunEvals;


    % Project Results into non-negative orthant
    if pArc == 1
        w(w < 0) = 0;
    end

    % Compute free variables
    %w(abs(w) < threshold) = 0;
    free = ones(p,1);
    free(abs(w) < threshold & g >= 0) = 0;

    % Update log
    if verbose
        fprintf('%10d %10d %15.5e %15.5e %15.5e %5d\n',i,fEvals,t,f,sum(abs(g(free==1))),sum(abs(w(1:p/2)-w(p/2+1:end))>threshold));
    end

    if sum(abs(g(free==1))) < optTol
        if verbose
            fprintf('Solution Found\n');
        end
        break;
    end
    if sum(free==1) == 0
        break;
    end

    if noProgress(t*d,f,f_old,optTol,verbose)
        break;
    end

    i = i +1;
end

w = w(1:length(w)/2)-w(length(w)/2 + 1:end);

end

function [f,g,H] = projNonNegGrad(w,lambda,gradFunc,varargin)

w(w < 0) = 0;
if nargout == 1
    f = nonNegGrad(w,lambda,gradFunc,varargin{:});
elseif nargout == 2
    [f,g] = nonNegGrad(w,lambda,gradFunc,varargin{:});
else
    [f,g,H] = nonNegGrad(w,lambda,gradFunc,varargin{:});
end

end
