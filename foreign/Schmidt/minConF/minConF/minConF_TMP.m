function [x,f,funEvals] = minConF_BC(funObj,x,LB,UB,options)
% function [x,f] = minConF_BC(funObj,x,LB,UB,options)
%
% Function for using Two-Metric Projection to solve problems of the form:
%   min funObj(x)
%   s.t. LB_i <= x_i <= UB_i
%
%   @funObj(x): function to minimize (returns gradient as second argument)
%
%   options:
%       verbose: level of verbosity (0: no output, 1: final, 2: iter (default), 3:
%       debug)
%       optTol: tolerance used to check for progress (default: 1e-7)
%       maxIter: maximum number of calls to funObj (default: 250)
%       numDiff: compute derivatives numerically (0: use user-supplied
%       derivatives (default), 1: use finite differences, 2: use complex
%       differentials)
%       method: 'sd', 'lbfgs', 'newton'

nVars = length(x);

% Set Parameters
if nargin < 5
    options = [];
end
[verbose,numDiff,optTol,maxIter,suffDec,interp,method,corrections,damped] = ...
    myProcessOptions(...
    options,'verbose',3,'numDiff',0,'optTol',1e-6,'maxIter',500,'suffDec',1e-4,...
    'interp',1,'method','lbfgs','corrections',100,'damped',0);

% Output Log
if verbose >= 3
    fprintf('%10s %10s %15s %15s %15s\n','Iteration','FunEvals','Step Length','Function Val','Opt Cond');
end

% Make objective function (if using numerical derivatives)
funEvalMultiplier = 1;
if numDiff
    if numDiff == 2
        useComplex = 1;
    else
        useComplex = 0;
    end
    funObj = @(x)autoGrad(x,useComplex,funObj);
    funEvalMultiplier = nVars+1-useComplex;
end

% Evaluate Initial Point
x = projectBounds(x,LB,UB);
if strcmp(method,'newton')
    [f,g,H] = funObj(x);
    secondOrder = 1;
else
    [f,g] = funObj(x);
    secondOrder = 0;
end
funEvals = 1;

% Compute Working Set
working = ones(nVars,1);
working((x < LB+optTol*2) & g >= 0) = 0;
working((x > UB-optTol*2) & g <= 0) = 0;
working = find(working);

% Check Optimality
if isempty(working)
    if verbose >= 1
        fprintf('All variables are at their bound and no further progress is possible at initial point\n');
    end
    return;
elseif norm(g(working)) <= optTol
    if verbose >=1
        fprintf('All working variables satisfy optimality condition at initial point\n');
    end
    return;
end

if verbose >= 3
    switch method
        case 'sd'
            fprintf('Steepest Descent\n');
        case 'lbfgs'
            fprintf('L-BFGS\n');
        case 'bfgs'
            fprintf('BFGS\n');
        case 'newton'
            fprintf('Newton\n');
    end
end

i = 1;
while funEvals <= maxIter

    % Compute Step Direction
    d = zeros(nVars,1);
    switch(method)
        case 'sd'
            d(working) = -g(working);
        case 'lbfgs'
            if i == 1
                d(working) = -g(working);
                old_dirs = zeros(nVars,0);
                old_stps = zeros(nVars,0);
                Hdiag = 1;
            else
                if damped
                    [old_dirs,old_stps,Hdiag] = dampedUpdate(g-g_old,x-x_old,corrections,verbose==3,old_dirs,old_stps,Hdiag);
                else
                    [old_dirs,old_stps,Hdiag] = lbfgsUpdate(g-g_old,x-x_old,corrections,verbose==3,old_dirs,old_stps,Hdiag);
                end
                    curvSat = sum(old_dirs(working,:).*old_stps(working,:)) > 1e-10;
               d(working) = lbfgs(-g(working),old_dirs(working,curvSat),old_stps(working,curvSat),Hdiag);
            end
            g_old = g;
            x_old = x;
        case 'bfgs'
            if i == 1
                d(working) = -g(working);
                B = eye(nVars);
            else
                y = g-g_old;
                s = x-x_old;

                ys = y'*s;

                if i == 2
                    if ys > 1e-10
                        B = ((y'*y)/(y'*s))*eye(nVars);
                    end
                end
                if ys > 1e-10
                    B = B + (y*y')/(y'*s) - (B*s*s'*B)/(s'*B*s);
                else
                    if verbose == 2
                        fprintf('Skipping Update\n');
                    end
                end
                d(working) = -B(working,working)\g(working);
            end
            g_old = g;
            x_old = x;

        case 'newton'
            [R,posDef] = chol(H(working,working));
            
            if posDef == 0
                d(working) = -R\(R'\g(working));
            else
                if verbose == 3
                    fprintf('Adjusting Hessian\n');
                end
                H(working,working) = H(working,working) + eye(length(working)) * max(0,1e-12 - min(real(eig(H(working,working)))));
                d(working) = -H(working,working)\g(working);
            end
        otherwise
            fprintf('Unrecognized Method: %s\n',method);
            break;
    end

    % Check that Progress can be made along the direction
    f_old = f;
    gtd = g'*d;
    if gtd > -optTol
        if verbose >= 2
            fprintf('Directional Derivative below optTol\n');
        end
        break;
    end

    % Select Initial Guess to step length
    if i == 1 && ~secondOrder
        t = min(1,1/sum(abs(g(working))));
    else
        t = 1;
    end

    % Evaluate the Objective and Projected Gradient at the Initial Step
    x_new = projectBounds(x+t*d,LB,UB);
    if secondOrder
        [f_new,g_new,H] = funObj(x_new);
    else
        [f_new,g_new] = funObj(x_new);
    end
    funEvals = funEvals+1;

    % Backtracking Line Search
    lineSearchIters = 1;
    while f_new > f + suffDec*g'*(x_new-x) || ~isLegal(f_new)
        temp = t;
        if interp == 0 || ~isLegal(f_new) || ~isLegal(g_new)
            if verbose == 3
                fprintf('Halving Step Size\n');
            end
            t = .5*t;
        else
            if verbose == 3
                fprintf('Cubic Backtracking\n');
            end
            t = polyinterp([0 f gtd; t f_new g_new'*d]);
        end

        % Adjust if change is too small
        if t < temp*1e-3
            if verbose == 3
                fprintf('Interpolated value too small, Adjusting\n');
            end
            t = temp*1e-3;
        elseif t > temp*0.6
            if verbose == 3
                fprintf('Interpolated value too large, Adjusting\n');
            end
            t = temp*0.6;
        end

        % Check whether step has become too small
        if sum(abs(t*d)) < optTol
            if verbose == 3
                fprintf('Line Search failed\n');
            end
            t = 0;
            f_new = f;
            g_new = g;
            break;
        end

        % Evaluate New Point
        x_new = projectBounds(x+t*d,LB,UB);
        [f_new,g_new] = funObj(x_new);
        funEvals = funEvals+1;
        lineSearchIters = lineSearchIters+1;

    end

    % Take Step
    x = x_new;
    f = f_new;
    g = g_new;

    % Compute Working Set
    working = ones(nVars,1);
    working((x < LB+optTol*2) & g >= 0) = 0;
    working((x > UB-optTol*2) & g <= 0) = 0;
    working = find(working);

    % Output Log
    if verbose >= 2
        fprintf('%10d %10d %15.5e %15.5e %15.5e\n',i,funEvals*funEvalMultiplier,t,f,sum(abs(g(working))));
    end

    % Check Optimality
    if isempty(working)
        if verbose >= 1
            fprintf('All variables are at their bound and no further progress is possible\n');
        end
        break;
    elseif norm(g(working)) <= optTol
        if verbose >=1
            fprintf('All working variables satisfy optimality condition\n');
        end
        break;
    end

    % Check for lack of progress
    if sum(abs(t*d)) < optTol
        if verbose >= 1
            fprintf('Step size below optTol\n');
        end
        break;
    end

    if abs(f-f_old) < optTol
        if verbose >= 1
            fprintf('Function value changing by less than optTol\n');
        end
        break;
    end

    if funEvals*funEvalMultiplier > maxIter
        if verbose >= 1
            fprintf('Function Evaluations exceeds maxIter\n');
        end
        break;
    end

    % If necessary, compute Hessian
    if secondOrder && lineSearchIters > 1
        [f_new,g_new,H] = funObj(x);
    end

    i = i + 1;
end
end

function [x] = projectBounds(x,LB,UB)
x(x < LB) = LB(x < LB);
x(x > UB) = UB(x > UB);
end