function [mu, Sigma, iter, ll] = mvtFixedDofFitEm(X, dof, useSpeedup)
% Fit multivariate student T distribution  usign EM
% We assume the degrees of freedom parameter is fixed.
% X(i,:) is i'th case
% If useSpeedup = true, we use the data augmentation trick
%   of Meng and van Dyk

if nargin < 3, useSpeedup = true; end
[N D] = size(X);
mu = mean(X)';
Sigma = cov(X);
iter = 1;
maxIter = 20;
tol = 1e-3;
done = false;
ll = -inf;
while ~done
   % E step
   SigmaInv = inv(Sigma);
   XC = bsxfun(@minus,X,rowvec(mu));
   delta =  sum(XC*SigmaInv.*XC,2); % mahalanobis distance
   w = (dof+D) ./ (dof+delta); % E[tau(i)]
   if useSpeedup
      aopt = 1/(dof+D);
      w = det(SigmaInv)^aopt * w;
   end
   
   % ESS
   Xw = X .* repmat(w(:), 1, D);
   Sw = sum(w);
   SX = sum(Xw, 1)'; % sum_i u(i) xi, a D*1 vector
   SXX = Xw'*X; % sum_i u(i) xi xi', a D*D matrix
     
   % M step
   mu = SX / Sw;
   if useSpeedup, denom = Sw; else denom = N; end
   Sigma = (1/denom)*(SXX - SX*SX'/Sw); % Liu,Rubin eqn 16
   
   % Assess convergence
   oldll = ll;
   ll = sum(studentLogpdf(X, mu, Sigma, dof));
   done = convergenceTest(ll, oldll, tol) || iter>maxIter;
   iter = iter + 1;
end

end
