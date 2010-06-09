function [w,fEvals] = L1GeneralPrimalDualLogBarrier(gradFunc,w,lambda,params,varargin)
%
% computes argmin_w: gradFunc(w,varargin) + sum lambda.*abs(w)
%
% Method used:
%   Primal-dual Log-barrier
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
%   2: Second-order

lambda(lambda==0) = 1e-5;

% Process input options
[verbose,maxIter,optTol,threshold,order,adjustStep,predictor,sigma,test] = ...
    myProcessOptions(params,'verbose',1,'maxIter',250,...
    'optTol',1e-6,'threshold',1e-4,'order',2,'adjustStep',0,'predictor',1,'sigma',.01,'test',0);

% Start log
if verbose
    fprintf('%10s %10s %15s %15s %15s %15s %15s\n','Iteration','FunEvals','Step Length','Function Val','pFea','dFea','dGap');
end

% initialize variables
p = length(w);
w = [w.*(w >= 0);w.*(w<=0)];
w(w==0) = 1e-2;
m = 2*p;
lam = ones(m,1);
d_primal = zeros(2*p,1);

% form constraints
F = -eye(m);

global free
free = ones(2*p,1);

% Evaluate Initial Point
if order == 2
    [f,g,H] = nonNegGrad(w,lambda,gradFunc,varargin{:});
else
    [f,g] = nonNegGrad(w,lambda,gradFunc,varargin{:});
end
fEvals = 1;

% Determine surrogate duality gap
eta = -w'*F'*lam;

for i = 1:maxIter
    f_old = f;
    w_old = w;
    lam_old = lam;

    % BFGS Update
    if order ~= 2
        if i == 1
            B = eye(2*p);
            g_prev = g;
            w_prev = w;
        else
            [B,g_prev,w_prev] = bfgsUpdate(B,w,w_prev,g,g_prev,0);
        end
        H = B;
    end

    % Compute Duality Gap with Affine Scaling Direction and update
    % centering parameter
    if order == 2 && predictor
        r_primal = g + F'*lam;
        r_dual = -diag(lam)*F*w;
        W = F'*diag(F*w)^-1;
        b = - r_primal - W*r_dual;
        A = H - W*diag(lam)*F;
        d_primal = A\b;
        d_dual = -diag(F*w)^-1 * (-r_dual + diag(lam)*F*d_primal);
        t_primal = min([1;-.99*w(d_primal < 0)./d_primal(d_primal < 0)]);
        t_dual = min([1;-.99*lam(d_dual < 0)./d_dual(d_dual < 0)]);
        w_new = w + t_primal*d_primal;
        lam_new = lam + t_dual*d_dual;
        eta_affine = -w_new'*F'*lam_new;
        sigma = (eta_affine/eta)^3;
    end

    % Update barrier parameter
    mu = sigma*eta/m;

    % Compute residual
    r_primal = g + F'*lam;
    r_dual = -diag(lam)*F*w - mu;
    r_norm = norm([r_primal;r_dual]);

    % Solve for newton direction
    W = F'*diag(F*w)^-1;
    b = - r_primal - W*r_dual;
    A = H - W*diag(lam)*F;

    d_primal = A\b;
    d_dual = -diag(F*w)^-1 * (-r_dual + diag(lam)*F*d_primal);

    % Compute the step length
    t = 1;

    % Truncate step to ensure non-negative primal and dual variables
    t_primal = min([t;-.99*w(d_primal < 0)./d_primal(d_primal < 0)]);
    t_dual = min([t;-.99*lam(d_dual < 0)./d_dual(d_dual < 0)]);

    % Compute residual at full step
    w_new = w + t_primal*d_primal;
    lam_new = lam + t_dual*d_dual;
    if order == 2
        [f_new,g_new,H_new] = nonNegGrad(w_new,lambda,gradFunc,varargin{:});
    else
        [f_new,g_new] = nonNegGrad(w_new,lambda,gradFunc,varargin{:});
    end
    fEvals = fEvals + 1;
    r_primal_new = g_new + F'*lam_new;
    r_dual_new = -diag(lam_new)*F*w_new - mu;
    r_norm_new = norm([r_primal_new;r_dual_new]);

    % Backtracking line search
    while r_norm_new > (1 - 1e-4*min(t_primal,t_dual))*r_norm
        if verbose
            fprintf('Backtracking\n');
        end
        if t_primal ~= t_dual
            % Having different step lengths helps convergence,
            %   but not yield a descent direction,
            %   correct for this before backtracking
            t_primal = min(t_primal,t_dual);
            t_dual = t_primal;
        else
            t_primal = t_primal/2;
            t_dual = t_dual/2;
        end

        w_new = w + t_primal*d_primal;
        lam_new = lam + t_dual*d_dual;
        if order == 2
            [f_new,g_new,H_new] = nonNegGrad(w_new,lambda,gradFunc,varargin{:});
        else
            [f_new,g_new] = nonNegGrad(w_new,lambda,gradFunc,varargin{:});
        end
        fEvals = fEvals + 1;
        r_primal_new = g_new + F*lam_new;
        r_dual_new = -diag(lam_new)*F*w_new - mu;
        r_norm_new = norm([r_primal_new;r_dual_new]);

        if sum(abs(t_primal*d_primal)+abs(t_dual*d_dual)) < optTol
            break;
        end
    end

    % Take step
    w = w_new;
    lam = lam_new;
    f = f_new;
    g = g_new;
    if order == 2
        H = H_new;
    end
    r_primal = r_primal_new;
    r_dual = r_dual_new;
    eta = -w'*F'*lam;


    % Update log
    if verbose
        fprintf('%10d %10d %15.5e %15.5e %15.5e %15.5e %15.5e\n',i,fEvals,min(t_primal,t_dual),f,norm(r_primal),norm(r_dual),eta);
    end
    if any(w < 0)
        fprintf('Primal Infeasible\n');
        return;
    end
    if any(lam < 0)
        fprintf('Dual Infeasible\n');
        return;
    end
    if any(F*w >= 0)
        fprintf('Constraints Violated\n');
        return;
    end

    % Check termination

    if norm(r_primal) < optTol && norm(r_dual) < optTol && eta < optTol
        if verbose
            fprintf('Solution Found\n');
        end
        break;
    elseif noProgress([t_primal*d_primal;t_dual*d_dual],f,f_old,optTol,verbose)
        break;
    end

end
w = w(1:p)-w(p+1:end);
end
