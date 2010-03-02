function [beta,iter] = LassoShooting(X, y, lambda,varargin)
    % min_w ||Xw-y||_2^2 + lambda ||w||_1
    % Coordinate descent method  ("Shooting"), [Fu, 1998]
    
    [n p] = size(X);
    [maxIter, optTol, verbose, beta,offsetAdded] = ...
        process_options(varargin, 'maxIter',10000, 'optTol',1e-5, 'verbose', 0,...
        'w0', [],'offsetAdded',false);
    if isempty(beta)
        if(offsetAdded)
            lam = repmat(lambda,p,1); lam(1) = 0;
            beta = (X'*X + diag(sqrt(lam)))\(X'*y);
        else
            beta = (X'*X + sqrt(lambda)*eye(p))\(X'*y);
        end
    end
    iter = 0;
    XX2 = X'*X*2;
    Xy2 = X'*y*2;
    converged = 0;
    while ~converged && (iter < maxIter)
        beta_old = beta;
        if(offsetAdded)  % don't penalize offset, i.e. use a lambda value of 0
            c1 = Xy2(1) - sum(XX2(1,:)*beta) + XX2(1,1)*beta(1);
            a1 = XX2(1,1);
            if c1 == 0
                beta(1,1) = 0;
            else
                beta(1,1) = c1/a1;
            end
            start = 2;
        else
            start = 1;
        end
        for j = start:p
            cj = Xy2(j) - sum(XX2(j,:)*beta) + XX2(j,j)*beta(j);
            aj = XX2(j,j);
            if cj < -lambda
                beta(j,1) = (cj + lambda)/aj;
            elseif cj > lambda
                beta(j,1) = (cj  - lambda)/aj;
            else
                beta(j,1) = 0;
            end
        end
        iter = iter + 1;
        converged = (sum(abs(beta-beta_old)) < optTol);
    end
    
