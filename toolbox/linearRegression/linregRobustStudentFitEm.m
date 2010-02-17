function model = linregRobustStudentFitEm(X, y, dof,  includeOffset)
% Fit linear regression with Student noise model by EM

%#author Hannes Bretschneider
%#modified Kevin Murphy

if nargin < 4, includeOffset = true; end
if nargin < 5, relTol = 10^-6; end
if dof==0, dof = []; end

[N, D] = size(X);
Xtrain = X;
if includeOffset
  X = [ones(N, 1), X];
end


n = length(y);
w = X\y;
sigma2 = 1/n*sum((y - X*w).^2);
iter = 0;
if isempty(dof)
  estimateDof = true;
  dof = 10;  % initial guess
else
  estimateDof = false;
end

converged = false;
while ~converged
  iter = iter+1;
  w_old = w;
  delta = 1/sigma2*(y - X*w).^2;
  s = (dof+1)./(dof+delta);
  S  = diag(sqrt(s));
  x_weighted = S*X;
  y_weighted = S*y;
  w = x_weighted\y_weighted;
  sigma2 = 1/(n)*sum(s.*(y - X*w).^2);
  w_diff = max(abs(w_old./w-1));
  converged =  (w_diff < relTol);
  
  if estimateDof
    % optimize neg log likelihood of observed data (ECME)
    % using gradient free optimizer.
    nllfn = @(v) -sum(linregRobustStudentLogprob(...
      struct('w0', w(1), 'w', w(2:end), 'sigma2', sigma2, 'dof', v, 'includeOffset', includeOffset),...
      Xtrain, y));
    dofMax = 100; dofMin = 0.1;
    dof = fminbnd(nllfn, dofMin, dofMax); 
  end
end


model = struct('w', w, 'sigma2', sigma2, 'dof', dof,...
  'relTol', relTol, 'iterations', iter, 'includeOffset', includeOffset);

model.w0 = model.w(1);
model.w = model.w(2:end);

end
