function model = linregL1FitShooting(X, y, lambda, includeOffset)
%% min_w ||Xw-y||_2^2 + lambda ||w||_1
% Coordinate descent method  ("Shooting"), [Fu, 1998]
    
    if nargin < 4, includeOffset = true; end
    [n d] = size(X);
    init = linregL2Fit(X, y, lambda, includeOffset); % initialize with ridge estimate
    w = init.w;
    if includeOffset
        X = [ones(n, 1) X];
        d = d+1;
    end
   
    XX2 = X'*X*2;
    Xy2 = X'*y*2;
    
    w_old = w;
    if(includeOffset)  % don't penalize offset, i.e. use a lambda value of 0
        c1 = Xy2(1) - sum(XX2(1, :)*w) + XX2(1, 1)*w(1);
        a1 = XX2(1, 1);
        if c1 == 0
            w(1, 1) = 0;
        else
            w(1, 1) = c1/a1;
        end
        start = 2;
    else
        start = 1;
    end    
    iter = 0; maxIter = 10000; optTol = 1e-5;
    converged = false;
    while ~converged && (iter < maxIter)
        for j = start:d
            cj = Xy2(j) - sum(XX2(j, :)*w) + XX2(j, j)*w(j);
            aj = XX2(j, j);
            if cj < -lambda
                w(j, 1) = (cj + lambda)/aj;
            elseif cj > lambda
                w(j, 1) = (cj  - lambda)/aj;
            else
                w(j, 1) = 0;
            end
        end
        iter = iter + 1;
        converged = (sum(abs(w-w_old)) < optTol);
        w_old = w;
    end
    model.w = w;
    model.includeOffset = includeOffset;
    model.sigma2 = var((X*w - y).^2); % MLE
end