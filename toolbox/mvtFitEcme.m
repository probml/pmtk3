function [mu, Sigma, dof, iter] = mvtFitEcme(X, useSpeedup, verbose)
% Fit multivariate student T distribution usign ECME
% X(i,:) is i'th case
% To estimate the dof, we use the ECME algorithm of
%   Liu and Rubin Statisitic Sinica 1995
% If useSpeedup = true, we use the data augmentation trick
%   of Meng and van Dyk

if nargin < 2, useSpeedup = false; end
if nargin < 3, verbose = false; end
[N D] = size(X);
ntrials = 10;
saveMu = zeros(D, ntrials);
saveSigma = zeros(D,D,ntrials);
saveDof = zeros(1,ntrials);
ll = -inf;
dofMax = 1000; dofMin = 0.1;
timeMinconf = 0; timeFminbnd = 0;
for trial=1:ntrials
   if trial==1
      mu = mean(X)';
      Sigma = cov(X);
      dof = 20; % start with large dof near Gaussian
   else
      mu = randn(D,1);
      Sigma = diag(rand(D,1)); 
      dof = ceil(rand(1,1))*5;
   end
    if verbose, fprintf('starting trial %d of %d\n', trial, ntrials); end
   iter = 1;
   maxIter = 20;
   tol = 1e-3;
   done = false;
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
      SX = sum(Xw, 1)'; % sum_i u(i) xi, column vector
      SXX = Xw'*X; % sum_i u(i) xi xi'
      
      % M step
      mu = SX / Sw;
      if useSpeedup, denom = Sw; else denom = N; end
      Sigma = (1/denom)*(SXX - SX*SX'/Sw); % Liu,Rubin eqn 16
      
      % Estimate dof
      % compute neg log likelihood of observed data by plugging
      % in most recent params. 
      nllfn = @(v) -sum(mvtLogpdf(X, mu, Sigma, v));
      tic; 
      dof = fminbnd(nllfn, dofMin, dofMax);
      t=toc;
      timeFminbnd = timeFminbnd + t;
      
      if 0
      % or use gradient based method
      % eqn 30 from Liu and Rubin 1995 is the gradient of the observed data loglik
      % using the most recent values of mu and Sigma
      % This is not sufficiently much faster to be worth the complexity
       % re-do E step
       tic;
      SigmaInv = inv(Sigma);
      XC = bsxfun(@minus,X,rowvec(mu));
      delta =  sum(XC*SigmaInv.*XC,2); % mahalanobis distance
       %w = (dof+D) ./ (dof+delta); % E[tau(i)]
      wfn = @(v) (v+D)./(v+delta);
      gradfn = @(v) -N*(-psi(v/2)+log(v/2)+sum(log(wfn(v))-wfn(v))/N + 1 + ...
         psi((dof+D)/2)-log((dof+D)/2));
      % find zero of the gradient by doing a 1d line search
      fn = @(v) fnjoin(v, nllfn, gradfn);
      options.verbose = 0; 
      [dof2] = minConF_TMP(fn,dof,dofMin,dofMax,options);
      t=toc;
      timeMinconf = timeMinconf + t;
      assert(approxeq(dof, dof2))
      end
      
      % Assess convergence
      oldll = ll;
      ll = sum(mvtLogpdf(X, mu, Sigma, dof));
      done = convergenceTest(ll, oldll, tol) || iter>maxIter;
      iter = iter + 1;
   end
   loglik(trial) = sum(mvtLogpdf(X, mu, Sigma, dof));
   saveMu(:,trial) = mu(:);
   saveSigma(:,:,trial) = Sigma;
   saveDof(trial) = dof;
end

%[timeFminbnd timeMinconf]

best = argmax(loglik);
mu = saveMu(:,best);
Sigma = saveSigma(:,:,best);
dof = saveDof(best);
end
