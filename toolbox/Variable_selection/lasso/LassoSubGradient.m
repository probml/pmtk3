function [w,wp,iteration] = LassoSubGradient(X,y,lambda,varargin)
% This function computes the Least Squares parameters
% with a penalty on the L1-norm of the parameters
%
% Method used:
%   Sub-Gradient Descent on non-zero and zero but non-optimal variables
%   taking Newton steps on the sub-gradients
%
% Note: This method strictly removes variables that goes to 0.  It could
%   be modified to allow the re-introduction of variables currently at 0,
%   by re-inserting them into the QR factorization when they become free
[maxIter,verbose,optTol,threshold] = process_options(varargin,'maxIter',10000,'verbose',2,'optTol',1e-5,'zeroThreshold',1e-4);
[n p] = size(X);

w = (X'*X + lambda*eye(p))\(X'*y);

if verbose == 2
    fprintf('%6s %6s %15s %15s %15s %5s\n','iter','fEvals','stepLen','f(w)','optCond','free');
    j=1;
    wp = w;
end

Xy = X'*y;
XX = X'*X;
yy = y'*y;
fevals = 0;
[Q,R] = qr(X,0);
free = ones(p,1);
t = 1;
[f,g] = LassoObj(w,XX,Xy,yy,lambda,threshold);
fevals = fevals+1;
for iteration = 0:maxIter

    free_qr = free;
    free = ones(p,1);
    free(abs(w)<=threshold & abs(g) <= lambda+optTol) = 0;

    while sum(free~=free_qr) > 0
        % Find an element that needs to be deleted
        [mx mxPos] = max(free_qr-free);
        qrPos = mxPos-sum(free_qr(1:mxPos-1)==0);

        % Delete the element from the factorization
        w(mxPos) = 0;
        [Q,R] = qrdelete(Q,R,qrPos,'col');
        free_qr(mxPos) = free(mxPos);
        t = 1;
    end

    d = zeros(p,1);
    d(free==1) = -(R\(R'\g(free==1)));

    gtd = g'*d;
    [f_td,g_td] = LassoObj(w+t*d,XX,Xy,yy,lambda,threshold);
    fevals = fevals+1;
    while f_td > f + 1e-4*t*gtd
        % Cubic backtracking
        gtd_new = g_td'*d;
        d1 = gtd + gtd_new - 3*(f-f_td)/(0-t);
        d2 = sqrt(d1^2 - gtd*gtd_new);
        t = t - (t - 0)*((gtd_new + d2 - d1)/(gtd_new - gtd + 2*d2));
        % Take step
        [f_td,g_td] = LassoObj(w+t*d,XX,Xy,yy,lambda,threshold);
        fevals = fevals+1;
    end

    w = w + t*d;

    if verbose == 2
        g = XX*w-Xy;
        OC= sum(abs(g(abs(w)>threshold) + lambda*sign(w(abs(w)>threshold))))+sum(abs(g(abs(w)<=threshold)) > lambda);
        fprintf('%6d %6d %15.5e %15.5e %15.5e %5d\n',iteration,fevals,t*.25,...
            sum((X*w-y).^2)+lambda*sum(abs(w)),OC,sum(free));
        j=j+1;
        wp(:,j) = w;
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
end

function [f,g] = LassoObj(w,XX,Xy,yy,lambda,threshold)
    f = sum(w'*XX*w - 2*w'*Xy + yy) + lambda*sum(abs(w));
    if nargout > 1
        g = computeSlope(w,lambda/2,XX*w-Xy,threshold);
    end
end