function [w,wp,iteration] = LassoPrimalDualLogBarrier(X, y, lambda,varargin)
% This function computes the Least Squares parameters
% with a penalty on the L1-norm of the parameters
%
% Method used:
%   A Primal-Dual Log-Barrier Interior Point method (ie. [Chen, 1999]),
%   as described in [Sardy, 1998]
%
% Mode:
%   0 - Compute Newton direction by solving for dual variables first
%       (method outlined in paper, fast for n << p)
%   1 - Compute Newton direction by solving for primal variables first
%       (faster for p << n)
%   2 - Compute Newton direction by solving for dual slack first
%       (fast for p << n)
[n p] = size(X);
[maxIter,verbose,optTol,zeroThreshold,mu_0,gamma,mode] = process_options(varargin,'maxIter',10000,'verbose',2,'optTol',1e-7,'zeroThreshold',1e-4,'mu0',1,'gamma',.99,'mode',0);
epsilon_1 = optTol;
epsilon_2 = optTol;
if lambda == 0
    lambda = 1e-4;
else
    lambda = lambda/2;
end
% Define symbols as in Sardy's papaer
A = [X -X];
s = y;
% Find an initial point (Ridge Regression solution)
alpha = (X'*X + lambda*eye(p))\(X'*y);
alpha_plus = max(alpha,0);
alpha_minus = max(-alpha,0);
% initialize primal
x_0 = [alpha_plus;alpha_minus] + 0.1*ones(2*p,1);
% initialize dual
y_bar = A*sign([alpha_plus;alpha_minus]);
omega_hat = 1.1*norm(X'*y,inf);
y_0 = lambda*y_bar/omega_hat;
% initialize slack
z_0 = lambda*ones(2*p,1) - A'*y_0;
iteration = 0;
x_k = x_0;
y_k = y;
z_k = z_0;
mu_k = mu_0;
% Calculate initial KKT equations
r_x = -A'*y_k - z_k + lambda*ones(2*p,1);
r_y = s - A*x_k - y_k;
r_z = mu_k*ones(2*p,1) - diag(x_k)*diag(z_k)*ones(2*p,1);
% Start iteration log
if verbose==2
    fprintf('%5s %15s %15s %15s %15s %15s %15s\n','itn','n(w)','n(step)','f(w)','pFeas','dFeas','dGap');
    x_k_old = x_k;
    j=1;
    wp = x_k;
end

% while not exceeding iteration count
while iteration < maxIter
    % Update iteration log
    if verbose==2 && iteration > 0
        fprintf('%5d %15.2e %15.2e %15.2e %15.2e %15.2e %15.2e\n',iteration...
            ,sum(abs(x_k)),sum(abs(x_k-x_k_old)),...
            sum((y-A*x_k).^2)+2*lambda*sum(abs(x_k)),norm(r_y)/(1+norm(x_k))...
            ,norm(r_x)/(1+norm(y_k)),z_k'*x_k/(1+norm(x_k)*norm(y_k)));
        x_k_old = x_k;
        j=j+1;
        wp(:,j) = x_k;
    end

    % check optimality
    norm_xk = norm(x_k);
    norm_yk = norm(y_k);
    if (r_y'*r_y)/(1+norm_xk) < epsilon_1 && ...
            (r_x'*r_x)/(1+norm_yk) < epsilon_1 && ...
            z_k'*x_k/(1+norm_xk*norm_yk) < epsilon_2
        if verbose
            fprintf('Solution Found\n');
        end
        break;
    end

    % compute Newton direction
    X = diag(x_k);

    if mode == 0
        Zinv = diag(1./z_k);
        D = Zinv*X;
        [U,pd] = chol(eye(n)+A*D*A');
        if pd == 0
            delta_y = U \ (U'\(r_y - A*(((Zinv)*r_z) - D*r_x)));
        else
            delta_y = (eye(n)+A*D*A')\(r_y - A*(((Zinv)*r_z) - D*r_x));
            mu_k = mu_k/10;
        end
        delta_z = r_x - A'*delta_y;
        delta_x = Zinv*(r_z - X*delta_z);
    elseif mode == 1
        Z = diag(z_k);
        delta_x = (Z+X*A'*A)\(r_z - X*(r_x - A'*r_y));
        delta_y = r_y - A*delta_x;
        delta_z = r_x - A'*delta_y;
    else
        Zinv = diag(1./z_k);
        delta_z = (eye(2*p) + A'*A*Zinv*X)\(r_x - A'*r_y + A'*A*Zinv*r_z);
        delta_x = Zinv*(r_z - X*delta_z);
        delta_y = r_y - A*delta_x;
    end
    % compute step length
    alpha = find(delta_x < -0.0001);
    beta_x = min([1 (-x_k(alpha)./delta_x(alpha))']);
    alpha = find(delta_z < -0.0001);
    beta_yz = min([1 -(z_k(alpha)./delta_z(alpha))']);

    % take step
    x_k = x_k + gamma*beta_x*delta_x;
    y_k = y_k + gamma*beta_yz*delta_y;
    z_k = z_k + gamma*beta_yz*delta_z;

    % update mu

    mu_k = (1 - min([gamma beta_x beta_yz]))*mu_k;

    if mod(iteration+1,10)==0
        mu_k=mu_k/10;
    end

    % compute new KKT equations
    r_x = -A'*y_k - z_k + lambda*ones(2*p,1);
    r_y = s - A*x_k - y_k;
    r_z = mu_k*ones(2*p,1) - diag(x_k)*diag(z_k)*ones(2*p,1);

    iteration = iteration+1;

end
if verbose && iteration > maxIter
    fprintf('Terminated, too many iterations\n');
elseif verbose
    fprintf('Number of iterations: %d\n',iteration);
end
% Compute final weight vector
w = x_k(1:p)-x_k(p+1:2*p);
w(abs(w)<=zeroThreshold) = 0;

