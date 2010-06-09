function [w,wp,it] = LassoGrafting(X, y, lambda,varargin)
% This function computes the Least Squares parameters
% with a penalty on the L1-norm of the parameters
%
% Method used:
%   The Grafting method of [Perkins et al., 2003]
%   This method uses Matlab's fminunc
[maxIter,verbose,optTol,threshold] = process_options(varargin,'maxIter',10000,'verbose',2,'optTol',1e-5,'zeroThreshold',1e-4);
[n p] = size(X);
iteration = 0;
it = 0;
oldmaxpos = -1;
oldmaxpos2 = -1;
fval = inf;
options = optimset('Display','off','GradObj','on','MaxFunEvals',maxIter,'maxiter',maxIter-iteration,'LargeScale','on','tolFUN',optTol,'Hessian','on');
% NOTE: results seem to be sub-optimal with medium-scale algorithm
% (even though much faster)
% Initialize the free variable set
w = zeros(p,1);
free = zeros(p,1);
% Start the log
if verbose==2
    w_old = w;
    fprintf('%10s %10s %15s %15s %15s %5s %5s\n','iter','QN_iter','n(w)','n(step)','f(w)','opt(wi)','free');
    j=1;
    wp = w;
end
% Precompute sufficient statistics
Xy = X'*y;
XX = X'*X;
yy = y'*y;
while iteration < maxIter
    % Compute the gradient
    g = computeSlope(w,lambda/2,XX*w-Xy,threshold);
    % check optimality
    if sum(abs(g) <= lambda+optTol)==p
        if verbose
            fprintf('Solution Found\n');
        end
        break;
    end
    % find max magnitude variable and add to free variables
    [max_viol maxpos] = max(abs(g));
    free(maxpos) = 1;
    if oldmaxpos == maxpos && oldmaxpos == oldmaxpos2
        if verbose
            fprintf('Cant Introduce Anything, Terminating\n');
        end
        break;
    end
    oldmaxpos2=oldmaxpos;
    oldmaxpos=maxpos;
    % solve with all free variables
    old_fval = fval;
    [wtemp fval exitflag output] = fminunc(@LassoObj,w(free > 0),options,XX(free>0,free>0),Xy(free>0),yy,lambda,threshold);
    iteration = iteration+output.iterations;
    if abs(fval-old_fval) < optTol^2
        if verbose
            fprintf('Function Value not Decreasing\n');
            %break;
        end
    end
    % Update w
    w=zeros(p,1);
    w(free == 1) = wtemp;
    it = it+1;

    % Update the free variable set

    free = abs(w) >= threshold;

    % Update the log
    if verbose ==2
        g = XX*w-Xy;
        g = computeSlope(w,lambda,g,threshold);
        fprintf('%10d %10d %15.2e %15.2e %15.2e %5d %5d\n',it,iteration,sum(abs(w)),sum(abs(w-w_old)),sum((X*w-y).^2)+lambda*sum(abs(w)),sum(abs(g) <= 2*lambda+threshold),sum(free));
        w_old = w;
        j=j+1;
        wp(:,j) = w;
    end
end
if verbose
    fprintf('Number of iterations: %d\nNumber of Quasi-Newton iterations: %d\n',it,iteration);
end

end


function [f,g,H] = LassoObj(w,XX,Xy,yy,lambda,threshold)
% A function that returns the function value and gradient as defined
% in Shevade/Perkins

f = sum(w'*XX*w - 2*w'*Xy + yy) + lambda*sum(abs(w));
if nargout > 1
    g = computeSlope(w,lambda,2*XX*w-2*Xy,threshold);
end
if nargout > 2
    H = 2*XX;
end
end