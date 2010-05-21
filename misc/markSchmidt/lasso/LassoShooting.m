function [w,wp,m] = LassoShooting(X, y, lambda,varargin)
% This function computes the Least Squares parameters
% with a penalty on the L1-norm of the parameters
%
% Method used:
%   The Shooting method of [Fu, 1998]
%
% Modifications:
%   We precompute the Hessian diagonals, since they do not 
%   change between iterations
[maxIter,verbose,optTol,zeroThreshold] = process_options(varargin,'maxIter',10000,'verbose',2,'optTol',1e-5,'zeroThreshold',1e-4);
[n p] = size(X);

% Start from the Least Squares solution
beta = (X'*X + lambda*eye(p))\(X'*y);
% Start the log
if verbose==2
    w_old = beta;
    fprintf('%10s %10s %15s %15s %15s\n','iter','shoots','n(w)','n(step)','f(w)');
    k=1;
    wp = beta;
end

m = 0;

XX2 = X'*X*2;
Xy2 = X'*y*2;
while m < maxIter
    
    
    
    beta_old = beta;
    for j = 1:p
        
        % Compute the Shoot and Update the variable
        S0 = sum(XX2(j,:)*beta) - XX2(j,j)*beta(j) - Xy2(j);
        if S0 > lambda
            beta(j,1) = (lambda - S0)/XX2(j,j);
        elseif S0 < -lambda
            beta(j,1) = (-lambda - S0)/XX2(j,j);
        elseif abs(S0) <= lambda
            beta(j,1) = 0;
        end
        
    end
    
    m = m + 1;
    
    % Update the log
    if verbose==2
        fprintf('%10d %10d %15.4e %15.4e %15.4e\n',m,m*p,sum(abs(beta)),sum(abs(beta-w_old)),...
            sum((X*beta-y).^2)+lambda*sum(abs(beta)));
        w_old = beta;
        k=k+1;
        wp(:,k) = beta;
    end
    % Check termination
    if sum(abs(beta-beta_old)) < optTol
        break;
    end
    
    
end
if verbose
fprintf('Number of iterations: %d\nTotal Shoots: %d\n',m,m*p);
end
w = beta;
