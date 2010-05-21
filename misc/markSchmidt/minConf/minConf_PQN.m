function [x,f,funEvals] = minConf_PQN(funObj,x,funProj,options)
% function [x,f] = minConf_PQN(funObj,funProj,x,options)
%
% Function for using a limited-memory projected quasi-Newton to solve problems of the form
%   min funObj(x) s.t. x in C
%
% The projected quasi-Newton sub-problems are solved the spectral projected
% gradient algorithm
%
%   @funObj(x): function to minimize (returns gradient as second argument)
%   @funProj(x): function that returns projection of x onto C
%
%   options:
%       verbose: level of verbosity (0: no output, 1: final, 2: iter (default), 3:
%       debug)
%       optTol: tolerance used to check for optimality (default: 1e-5)
%       progTol: tolerance used to check for progress (default: 1e-9)
%       maxIter: maximum number of calls to funObj (default: 500)
%       maxProject: maximum number of calls to funProj (default: 100000)
%       numDiff: compute derivatives numerically (0: use user-supplied
%       derivatives (default), 1: use finite differences, 2: use complex
%       differentials)
%       suffDec: sufficient decrease parameter in Armijo condition (default: 1e-4)
%       corrections: number of lbfgs corrections to store (default: 10)
%       adjustStep: use quadratic initialization of line search (default: 0)
%       bbInit: initialize sub-problem with Barzilai-Borwein step (default: 1)
%       SPGoptTol: optimality tolerance for SPG direction finding (default: 1e-6)
%       SPGiters: maximum number of iterations for SPG direction finding (default:10)

nVars = length(x);

% Set Parameters
if nargin < 4
    options = [];
end
[verbose,numDiff,optTol,progTol,maxIter,maxProject,suffDec,corrections,adjustStep,bbInit,...
    SPGoptTol,SPGprogTol,SPGiters,SPGtestOpt] = ...
    myProcessOptions(...
    options,'verbose',2,'numDiff',0,'optTol',1e-5,'progTol',1e-9,'maxIter',500,'maxProject',100000,'suffDec',1e-4,...
    'corrections',10,'adjustStep',0,'bbInit',0,'SPGoptTol',1e-6,'SPGprogTol',1e-10,'SPGiters',10,'SPGtestOpt',0);

% Output Parameter Settings
if verbose >= 3
   fprintf('Running PQN...\n');
   fprintf('Number of L-BFGS Corrections to store: %d\n',corrections);
   fprintf('Spectral initialization of SPG: %d\n',bbInit);
   fprintf('Maximum number of SPG iterations: %d\n',SPGiters);
   fprintf('SPG optimality tolerance: %.2e\n',SPGoptTol);
   fprintf('SPG progress tolerance: %.2e\n',SPGprogTol);
   fprintf('PQN optimality tolerance: %.2e\n',optTol);
   fprintf('PQN progress tolerance: %.2e\n',progTol);
   fprintf('Quadratic initialization of line search: %d\n',adjustStep);
   fprintf('Maximum number of function evaluations: %d\n',maxIter);
   fprintf('Maximum number of projections: %d\n',maxProject);
end

% Output Log
if verbose >= 2
        fprintf('%10s %10s %10s %15s %15s %15s\n','Iteration','FunEvals','Projections','Step Length','Function Val','Opt Cond');
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

% Project initial parameter vector
x = funProj(x);
projects = 1;

% Evaluate initial parameters
[f,g] = funObj(x);
funEvals = 1;

% Check Optimality of Initial Point
projects = projects+1;
if max(abs(funProj(x-g)-x)) < optTol
    if verbose >= 1
        fprintf('First-Order Optimality Conditions Below optTol at Initial Point\n');
    end
    return;
end

i = 1;
while funEvals <= maxIter

    % Compute Step Direction
    if i == 1
        p = funProj(x-g);
        projects = projects+1;
        S = zeros(nVars,0);
        Y = zeros(nVars,0);
        Hdiag = 1;
    else
        y = g-g_old;
        s = x-x_old;
        [S,Y,Hdiag] = lbfgsUpdate(y,s,corrections,verbose==3,S,Y,Hdiag);

        % Make Compact Representation
        k = size(Y,2);
        L = zeros(k);
        for j = 1:k
            L(j+1:k,j) = S(:,j+1:k)'*Y(:,j);
        end
        N = [S/Hdiag Y];
        M = [S'*S/Hdiag L;L' -diag(diag(S'*Y))];
        HvFunc = @(v)lbfgsHvFunc2(v,Hdiag,N,M);

        if bbInit
            % Use Barzilai-Borwein step to initialize sub-problem
            alpha = (s'*s)/(s'*y);
            if alpha <= 1e-10 || alpha > 1e10
                alpha = min(1,1/sum(abs(g)));
            end

            % Solve Sub-problem
            xSubInit = x-alpha*g;
            feasibleInit = 0;
        else
            xSubInit = x;
            feasibleInit = 1;
        end
        % Solve Sub-problem
        [p,subProjects] = solveSubProblem(x,g,HvFunc,funProj,SPGoptTol,SPGprogTol,SPGiters,SPGtestOpt,feasibleInit,xSubInit);
        projects = projects+subProjects;
    end
    d = p-x;
    g_old = g;
    x_old = x;

    % Check that Progress can be made along the direction
    gtd = g'*d;
    if gtd > -progTol
        if verbose >= 1
            fprintf('Directional Derivative below progTol\n');
        end
        break;
    end

    % Select Initial Guess to step length
    if i == 1 || adjustStep == 0
       t = 1; 
    else
        t = min(1,2*(f-f_old)/gtd);
    end
    
    % Bound Step length on first iteration
    if i == 1
        t = min(1,1/sum(abs(g)));
    end

    % Evaluate the Objective and Gradient at the Initial Step
    if t == 1
        x_new = p;
    else
        x_new = x + t*d;
    end
    [f_new,g_new] = funObj(x_new);
    funEvals = funEvals+1;

    % Backtracking Line Search
    f_old = f;
    while f_new > f + suffDec*g'*(x_new-x) || ~isLegal(f_new)
        temp = t;
        
        % Backtrack to next trial value
        if ~isLegal(f_new) || ~isLegal(g_new)
            if verbose == 3
                fprintf('Halving Step Size\n');
            end
            t = t/2;
        else
            if verbose == 3
                fprintf('Cubic Backtracking\n');
            end
            t = polyinterp([0 f gtd; t f_new g_new'*d]);
        end

        % Adjust if change is too small/large
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
        if sum(abs(t*d)) < progTol || t == 0
            if verbose == 3
                fprintf('Line Search failed\n');
            end
            t = 0;
            f_new = f;
            g_new = g;
            break;
        end

        % Evaluate New Point
        f_prev = f_new;
        t_prev = temp;
        x_new = x + t*d;
        [f_new,g_new] = funObj(x_new);
        funEvals = funEvals+1;

    end

    % Take Step
    x = x_new;
    f = f_new;
    g = g_new;
    
    optCond = max(abs(funProj(x-g)-x));
    projects = projects+1;

    % Output Log
    if verbose >= 2
            fprintf('%10d %10d %10d %15.5e %15.5e %15.5e\n',i,funEvals*funEvalMultiplier,projects,t,f,optCond);
    end

    % Check optimality
        if optCond < optTol
            fprintf('First-Order Optimality Conditions Below optTol\n');
            break;
        end

    if max(abs(t*d)) < progTol
        if verbose >= 1
            fprintf('Step size below progTol\n');
        end
        break;
    end

    if abs(f-f_old) < progTol
        if verbose >= 1
            fprintf('Function value changing by less than progTol\n');
        end
        break;
    end

    if funEvals*funEvalMultiplier > maxIter
        if verbose >= 1
            fprintf('Function Evaluations exceeds maxIter\n');
        end
        break;
    end
    
    if projects > maxProject
        if verbose >= 1
            fprintf('Number of projections exceeds maxProject\n');
        end
        break;
    end
    
    i = i + 1;
%    pause
end
end


function [p,subProjects] = solveSubProblem(x,g,H,funProj,optTol,progTol,maxIter,testOpt,feasibleInit,x_init)
% Uses SPG to solve for projected quasi-Newton direction
options.verbose = 0;
options.optTol = optTol;
options.progTol = progTol;
options.maxIter = maxIter;
options.testOpt = testOpt;
options.feasibleInit = feasibleInit;

funObj = @(p)subHv(p,x,g,H);
[p,f,funEvals,subProjects] = minConf_SPG(funObj,x_init,funProj,options);
end

function [f,g] = subHv(p,x,g,HvFunc)
d = p-x;
Hd = HvFunc(d);
f = g'*d + (1/2)*d'*Hd;
g = g + Hd;
end