function [x,f,funEvals] = minConf_Sep(funObj1,funObj2,x,funProj,options)

if nargin < 5
    options = [];
end

[verbose,optTol,maxIter,memory] = myProcessOptions(options,'verbose',1,'optTol',1e-6,'maxIter',500,'memory',10);

if verbose
fprintf('%10s %10s %10s %15s %15s\n','Iteration','FunEvals','Projections','Step Length','Function Val');
end

% Evaluate Initial Objective

% This file is from pmtk3.googlecode.com

[f1,g] = funObj1(x);
f = f1+funObj2(x);
funEvals = 1;
projects = 0;

i = 1;
while 1

    if i == 1
        alpha = min(1,1/sum(abs(g)));
    else
        y = g-g_old;
        s = x-x_old;
        alpha = (s'*s)/(s'*y);
        if alpha <= 1e-10 || alpha > 1e10
            alpha = min(1,1/sum(abs(g)));
        end
    end

        x_old = x;
    f_old = f;
    g_old = g;

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

    x_new = funProj(x-alpha*g,alpha);
    projects = projects+1;
    [f1_new,g_new] = funObj1(x_new);
    f_new = f1_new + funObj2(x_new);
    funEvals = funEvals+1;

    while f_new > funRef
        if verbose
        fprintf('Backtracking\n');
        end
        alpha = alpha/2;
        x_new = funProj(x-alpha*g,alpha);
        projects = projects+1;
        [f1_new,g_new] = funObj1(x_new);
        f_new = f1_new + funObj2(x_new);
        funEvals = funEvals+1;
    end
    x = x_new;
    f = f_new;
    g = g_new;

    if verbose
    fprintf('%10d %10d %10d %15.5e %15.5e\n',i,funEvals,projects,alpha,f);
    end

    if sum(abs(x_old-x)) < optTol || sum(abs(f_old-f)) < optTol
        if verbose
        fprintf('Insufficient Progress\n');
        end
        break
    end

    if funEvals > maxIter
        if verbose
        fprintf('Exceeded maxIter funEvals\n');
        end
        break
    end

    i = i + 1;
end
