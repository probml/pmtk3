function w = linregFitL1Shooting(X, y, lambda)
%% min_w ||Xw-y||_2^2 + lambda ||w||_1
% Coordinate descent method  ("Shooting"), [Fu, 1998]
    
if lambda==0, w = X\y; return; end

 % initialize with ridge estimate
w = linregFitL2QR(X, y, lambda);


XX2 = X'*X*2;
Xy2 = X'*y*2;

w_old = w;
D = size(X,2);
iter = 0; maxIter = 10000; optTol = 1e-5; 
converged = false;
while ~converged && (iter < maxIter)
  for j = 1:D
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
w = w(:);

end