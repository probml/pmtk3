function [w,wp,iteration] = LassoActiveSet(X, y, t,varargin)
% This function computes the Least Squares parameters
% whose 1-Norm is less than t
%
% Method used:
%   Local Linearization and Active Set Method
%   Proposed in [Osborne et al., 2000], [Osborne et al., 2000b]
%
% Mode:
%   0: Maintain QR Factorization of X'*X
%   1: Maintain QR Factorization of X
%
% Modifications:
%   The initial method treats all variables equally on the first iteration
%   This implementation uses the heuristic suggested in Shevade/Perkins
%   to introduce the first variable, this avoids much of the complications
%   associated with sign infeasibility
[maxIter,verbose,optTol,threshold,mode,w0] = process_options(varargin,'maxIter',10000,'verbose',2,'optTol',1e-5,'zeroThreshold',1e-4,'mode',0,'w0',[]);
[n p] = size(X);
iteration = 0;
sigma_old = ones(p,1);
XX = X'*X;
Xy = X'*y;

% initialize
if isempty(w0)
    beta = zeros(p,1);
else
    beta = w0;
end
sigma = abs(beta) > threshold;
theta = sign(beta);

% Start log
if verbose==2
    fprintf('%10s %15s %15s %15s %5s %5s\n','iter','n(w)','n(step)','f(w)','opt(wi)','free');
    k=1;
    wp = beta;
end
while iteration < maxIter
    % Get the values associated with the active set
    beta_sigma = beta(sigma);
    theta_sigma = theta(sigma);
    if sum(sigma-sigma_old) ~= 0
        Xy_sigma = Xy(sigma);

        % QR insert
        if sum(sigma) <= 1 || iteration == 0
            if mode == 0
                [Q,R] = qr(XX(sigma,sigma),0);
            else
                [Q,R] = qr(X(:,sigma));
            end
        else
            [junk qrPos] = max(abs(sigma(sigma)-sigma_old(sigma)));
            if mode == 0
                [Q,R] = qrinsert(Q,R,qrPos,XX(s,sigma_old),'row');
                [Q,R] = qrinsert(Q,R,qrPos,XX(sigma,s),'col');
            else
                % The below seems to be really slow in matlab
                [Q,R] = qrinsert(Q,R,qrPos,X(:,s),'col');
            end
        end
    end
    % Solve the local linerization
    if mode == 0
        [beta_t,h] = solveKKT(sigma,theta_sigma,beta_sigma,Xy_sigma,Q,R,y,t,beta);
    else
        [beta_t,h] = solveKKT2(sigma,theta_sigma,beta_sigma,Q,R,y,t,beta);
    end

    % ============================================================
    % Code below is strictly to deal with the sign infeasible case
    % (doesn't usually get used)
    % ============================================================
    while ~(sum(sign(beta_t(sigma)) == theta_sigma) == size(theta_sigma,1))
        if verbose==2
            fprintf('Not Sign Feasible\n');
        end
        % A1: Find first zero-crossing
        min_gamma = 1;
        min_gamma_i = -1;
        for k = 1:size(beta,1)
            if (abs(beta(k)) > threshold)
                gamma = -beta(k)/h(k);
                if gamma > 0 && gamma < min_gamma
                    min_gamma = gamma;
                    min_gamma_i = k;
                end
            end
        end
        if min_gamma_i == -1;
            if verbose==2
                fprintf('Numerical breakdown, check for dependent columns\n');
            end
            break;
        end

        % A1: set beta to h truncated at first zero-crossing

        beta = beta + min_gamma*h;
        % A2: reverse sign of first zero-crossing
        theta(min_gamma_i) = -theta(min_gamma_i);
        % A2: recompute h
        theta_sigma = theta(sigma);
        beta_sigma = beta(sigma);
        if mode == 0
            [beta_t,h] = solveKKT(sigma,theta_sigma,beta_sigma,Xy_sigma,Q,R,y,t,beta);
        else
            [beta_t,h] = solveKKT2(sigma,theta_sigma,beta_sigma,Q,R,y,t,beta);
        end

        if sum(sign(beta_t(sigma)) == theta_sigma) == size(theta_sigma,1)
            if verbose==2
                fprintf('Now it is Sign Feasible\n');
            end
        else
            if verbose==2
            fprintf('It is still Sign Infeasible\n');
            end
            % A3: Remove the first zero-crossing from the active set
            sigma_old = sigma;
            sigma(min_gamma_i) = 0;
            beta(min_gamma_i) = 0;
            % A3: Reset beta(min_gamma) and theta(min_gamma)
            beta(min_gamma_i) = 0;
            theta(min_gamma_i) = 0;
            beta_sigma = beta(sigma);
            theta_sigma = theta(sigma);
            % A3: Recompute h
            Xy_sigma = Xy(sigma);
            % QR Update
            if mode == 0
                [Q,R] = qr(XX(sigma,sigma),0); % Could do a qr delete here instead
                [beta_t,h] = solveKKT(sigma,theta_sigma,beta_sigma,Xy_sigma,Q,R,y,t,beta);
            else
                [Q,R] = qr(X(:,sigma)); % Could do a qr delete here instead
                [beta_t,h] = solveKKT2(sigma,theta_sigma,beta_sigma,Q,R,y,t,beta);
            end
            
            if verbose == 2
                if sum(sign(beta_t(sigma)) == theta_sigma) == size(theta_sigma,1)
                    fprintf('Finally, it is sign feasible\n');
                else
                    fprintf('It is still, STILL, not sign feasible\nGoing another round\n');
                end
            end
        end
    end
    % =============================================
    % End of Code to deal with sign infeasible case
    % =============================================

    iteration = iteration+1;
    % compute violation
    v_denom = norm(Xy_sigma-X(:,sigma)'*X*beta_t,inf);
    if v_denom > 0
        v_t = (Xy-XX*beta_t)/v_denom;
    else
        v_t = (Xy-XX*beta_t)*inf;
    end
    j = p-sum(abs(beta_t) < threshold & abs(v_t) > 1+threshold);

    % update log
    if verbose==2
        fprintf('%10d %15.2e %15.2e %15.2e %5d %5d\n',iteration,sum(abs(beta_t)),sum(abs(beta_t-beta)),sum((X*beta-y).^2),sum(j),sum(sigma));
        k=k+1;
        wp(:,k) = beta_t;
    end
    % check for optimality
    if j == p || t == 0
        if verbose
            fprintf('All Components satisfy condition\n');
        end
        break;
    end

    % find and add the most violating variable
    % On the first iteration, all variables are equally violating
    % so we're going to use the Shevade/Perkins trick to introduce
    % a good first variable, this often means we may not have to deal with
    % sign feasibility later issues later
    if iteration == 1
        g = computeSlope(beta,t,XX*beta-Xy,threshold);
        [max_viol s] = max(abs(g));
    else
        [maxi s] = max(abs(sigma-1).*abs(v_t));
    end
    % update the active set
    sigma_old = sigma;
    sigma(s) = 1;
    theta(s) = sign(v_t(s));
    beta = beta_t;
end
if verbose
fprintf('Number of iterations: %d\n',iteration);
end
w = beta_t;

end



function [beta_t,h] = solveKKT(sigma,theta_sigma,beta_sigma,Xy_sigma,Q,R,y,t,beta)
% X'X = Q*R
% mu = max(0, theta'(X'X)^-1X'y - t) / theta'(X'X)^-1 theta)
% h = (X'X)^-1 * (X'(Y-Xw) - mu*theta)
mu_denom = (theta_sigma'*(R \ (Q'*theta_sigma)));
if mu_denom ~= 0
    mu = max(0,((theta_sigma'*(R \ (Q'*Xy_sigma))) - t)/mu_denom);
else
    mu = 0;
end
h = zeros(length(beta),1);
h(sigma == 1) = R \ (Q'*((Xy_sigma-Q*R*beta_sigma)-(mu*theta_sigma)));
beta_t = beta+h;
end


function [beta_t,h] = solveKKT2(sigma,theta_sigma,beta_sigma,Q,R,y,t,beta)
% X = Q*R
% mu = max(0, theta'(X'X)^-1X'y - t) / theta'(X'X)^-1 theta)
% h = (X'X)^-1 * (X'(Y-Xw) - mu*theta)
mu_denom = (theta_sigma'*(R\(R'\theta_sigma)));
if mu_denom > 0
    mu = max(0,(theta_sigma'*((R\(Q'*y))) - t) / mu_denom);
else
    mu = 0;
end
h = zeros(length(beta),1);
h(sigma == 1) = (R\(R'\(R'*(Q'*y-R*beta_sigma)-mu*theta_sigma)));
beta_t = beta+h;
end