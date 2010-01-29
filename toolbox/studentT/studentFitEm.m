function [mu, Sigma, dof, iter] = mvtFitEm(X, useSpeedup, verbose)
% Fit multivariate student T distribution usign ECME
% X(i,:) is i'th case
% To estimate the dof, we use the EM algorithm of
%   Liu and Rubin Statisitic Sinica 1995
% If useSpeedup = true, we use the data augmentation trick
%   of Meng and van Dyk

disp('warning: EM is very slow, use ECME instead')

if nargin < 2, useSpeedup = false; end
if nargin < 3, verbose = false; end
[N D] = size(X);
ntrials = 3;
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
      dof = 5; % start with large dof near Gaussian
   else
      mu = randn(D,1);
      Sigma = diag(rand(D,1)); 
      dof = ceil(rand(1,1))*5;
   end
   if verbose, fprintf('starting trial %d of %d\n', trial, ntrials); end
   iter = 1;
   maxIter = 30;
   tol = 1e-5;
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
       % re-do E step to get multicycle ECM algorithm
      SigmaInv = inv(Sigma);
      XC = bsxfun(@minus,X,rowvec(mu));
      delta =  sum(XC*SigmaInv.*XC,2); % new mahalanobis distance
      w = (dof+D) ./ (dof+delta); % E[tau(i)]
      
      
      negQfn = @(v) -(-N*psi(v/2)+N*v*0.5*log(v/2)...
         + (v/2)*sum(log(w)-w)  ...
         + psi((dof+D)/2)-log((dof+D)/2));
      gradfn = @(v) -N*(-psi(v/2)+log(v/2)+1+sum(log(w)-w)/N  ...
         + psi((dof+D)/2)-log((dof+D)/2));
      % find zero of the gradient by doing a 1d line search
      fn = @(v) fnjoin(v, negQfn, gradfn);
      options.verbose = 0; 
      options.numDiff = 0;
      [dof] = minConF_TMP(fn,dof,dofMin,dofMax,options)
       
      %options.display = 'off';
      %options.derivCheck = 1;
      %[dof] = minFunc(fn,dof,options)
      
      
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
