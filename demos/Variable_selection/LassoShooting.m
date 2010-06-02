function [beta,iter] = LassoShooting(X, y, lambda, varargin)
% min_w ||Xw-y||_2^2 + sum_j lambda(j) |w_j|
% Coordinate descent method  ("Shooting"), [Fu, 1998]

%PMTKauthor Mark Schmidt

[maxIter, optTol, verbose, beta] = ...
  process_options(varargin, 'maxIter',10000, 'optTol',1e-5, ...
  'verbose', 0, 'w0', []); %#ok

[n p] = size(X); %#ok
if isscalar(lambda), lambda = repmat(lambda, 1, p); end
if isempty(beta)
    beta = (X'*X + diag(sqrt(lambda)))\(X'*y); % init with ridge
end
iter = 0;
XX2 = X'*X*2;
Xy2 = X'*y*2;
converged = 0;
while ~converged && (iter < maxIter)
  beta_old = beta;
  for j =1:p
    cj = Xy2(j) - sum(XX2(j,:)*beta) + XX2(j,j)*beta(j);
    aj = XX2(j,j);
    if cj < -lambda(j)
      beta(j,1) = (cj + lambda(j))/aj;
    elseif cj > lambda
      beta(j,1) = (cj  - lambda(j))/aj;
    else
      beta(j,1) = 0;
    end
  end
  iter = iter + 1;
  converged = (sum(abs(beta-beta_old)) < optTol);
end

end
