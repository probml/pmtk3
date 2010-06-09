function [w,wp,it] = LassoSignConstraints(X, y, t, varargin)
% This function computes the Least Squares parameters
% whose 1-Norm is less than t
%
% Method used:
%   Quadratic Programming with Sequentially Introduced 'Sign' Constraints
%   The method suggested in [Tibshirani, 1994]
%
% Modifications:
%   We use a tolerance on the 1-Norm rather than a hard-comparison.
%   This makes the method require solving far fewer QPs (linear vs.
%   exponential in the number of variables) when the problem is highly
%   constrained.
[maxIter,verbose,optTol,zeroThreshold] = process_options(varargin,'maxIter',10000,'verbose',2,'optTol',1e-5,'zeroThreshold',1e-4);
% Start from the Least Squares Solution
w = X\y;
% Start the Log
if verbose==2
    w_old = w;
    fprintf('%10s %10s %15s %15s %15s\n','iter','QP_iter','n(w)','n(step)','f(w)');
    j=1;
    wp = w;
end
% Compute the first constraint
E = sign(w)';
% Precompute and Initialize
XX = X'*X;
yX = -y'*X;
it = 1;
iterations = 0;
options = optimset('Display','none','LargeScale','off');

% while the L1-norm of the parameters is above t
while sum(abs(w)) >= t+optTol && iterations < maxIter
    % Update the log
    if verbose ==2
        fprintf('%10d %10d %15.2e %15.2e %15.2e\n',it,iterations,sum(abs(w)),sum(abs(w-w_old)),sum((X*w-y).^2));
        w_old = w;
        j=j+1;
        wp(:,j) = w;
    end
    
    % Add the new sign constraint and solve the new QP
    E = [E;sign(w)'];
    [w fval exitflag output] = quadprog(XX,yX,E,t*ones(size(E,1),1),[],[],[],[],w,options);
    iterations = iterations+output.iterations;
    it = it + 1;
    
end
% Output the final iteration log
if verbose ==2
        fprintf('%10d %10d %15.2e %15.2e %15.2e\n',it,iterations,sum(abs(w)),sum(abs(w-w_old)),sum((X*w-y).^2));
        j=j+1;
        wp(:,j) = w;
end
if verbose && iterations > maxIter
    fprintf('Exceeded Number of Iterations\n');    
end
if verbose
fprintf('Final Number of Constraints: %d\nNumber of QP Iterations: %d\n',...
    size(E,1),iterations);
end
w(abs(w)<=zeroThreshold) = 0;
