function [w,wp,iteration] = LassoSubGradient(X,y,lambda,varargin)
% This function computes the Least Squares parameters
% with a penalty on the L1-norm of the parameters
%
% Method used:
%   Two-Metric Projection

[maxIter,verbose,optTol,threshold] = process_options(varargin,'maxIter',10000,'verbose',2,'optTol',1e-5,'zeroThreshold',1e-4);
[n p] = size(X);


w = (X'*X + lambda*eye(p))\(X'*y);
w = [w.*(w > 0);-w.*(w<0)];

if verbose == 2
    fprintf('%6s %6s %15s %15s %5s\n','iter','fEvals','stepLen','f(w)','free');
    j=1;
    wp = w(1:p)-w(p+1:end);
end

Xy = X'*y;
XX = X'*X;
yy = y'*y;
fevals = 0;
[f,g] = LassoObj(w,XX,Xy,yy,lambda);
H = 2*[XX -XX;-XX XX];
fevals = fevals+1;
for iteration = 0:maxIter

    % Compute free variables
    w(abs(w) < threshold) = 0;
    free = ones(2*p,1);
    free(w==0 & g >= 0) = 0;
    
    if sum(abs(g(free==1))) < optTol
        if verbose
            fprintf('Solution Found\n');
        end
        break;
    end
    if sum(free==1) == 0
        break;
    end

    % Compute descent direction
    d = zeros(2*p,1);
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
    
    t = 1;

    % Adjust on first iteration
    if i == 1
        t = min(1,1/sum(abs(g(free==1))));
    end
    
    gtd = g'*d;
    
    [f_td,g_td] = LassoObj(w+t*d,XX,Xy,yy,lambda);
    fevals = fevals+1;
    while f_td > f + 1e-4*t*gtd
        % Cubic backtracking
        gtd_new = g_td'*d;
        d1 = gtd + gtd_new - 3*(f-f_td)/(0-t);
        d2 = sqrt(d1^2 - gtd*gtd_new);
        t = t - (t - 0)*((gtd_new + d2 - d1)/(gtd_new - gtd + 2*d2));
        % Take step
        [f_td,g_td] = LassoObj(w+t*d,XX,Xy,yy,lambda);
        fevals = fevals+1;
    end

    w = w + t*d;
    w(w < 0) = 0;

    if verbose == 2
        fprintf('%6d %6d %15.5e %15.5e %5d\n',iteration,fevals,sum(abs(t*d)),...
            f_td,sum(free));
        j=j+1;
        wp(:,j) = w(1:p)-w(p+1:end);
    end

    if sum(abs(t*d)) < optTol
        if verbose
            fprintf('Number of Iterations: %d, Number of function Evaluations: %d\n',iteration,fevals);
        end
        break;
    end
    
    f = f_td;
    g = g_td;
end
w = w(1:p)-w(p+1:end);
end

function [f,g] = LassoObj(wFull,XX,Xy,yy,lambda)
    % Project
    wFull(wFull < 0) = 0;

    % Compute gradient
    p = size(XX,1);
    w = wFull(1:p)-wFull(p+1:end);
    XXw = XX*w;
    f = sum(w'*XXw - 2*w'*Xy + yy) + lambda*sum(wFull);
    if nargout > 1
        g = 2*XXw - 2*Xy;
        g = [g;-g] + lambda;
    end
end