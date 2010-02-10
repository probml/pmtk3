function [model, iter] = studentFitEm(X, dof,  useECME, useSpeedup, verbose)
% Fit multivariate student T distribution usign ECME
% X(i,:) is i'th case
% If dof is unknown, set it to [].
% model  is a structure containing fields: mu, Sigma, dof
% For a scalar distribution, Sigma is the variance
%
% If dof is unknown, 
% we estimate it using the EM algorithm of
%   Liu and Rubin Statisitic Sinica 1995
% If useECME = true, we optimize dof wrt the 
% observed data log likelihood (ECME = expectation conditional
% maximize of either Q or loglik)
%
% If useSpeedup = true, we use the data augmentation trick
%   of Meng and van Dyk

if nargin < 2, dof = []; end
if nargin < 3, useECME = true; end
if nargin < 4, useSpeedup = true; end
if nargin < 4, verbose = false; end

if isempty(dof), estimateDof = true; else estimateDof = false; end

if isvector(X)
  X = X(:);
end
D = size(X,2);
ntrials = 1;
saveMu = zeros(D, ntrials);
saveSigma = zeros(D,D,ntrials);
saveDof = zeros(1,ntrials);
loglik = zeros(1, ntrials);
niter = zeros(1, ntrials);

for trial=1:ntrials
   if trial==1
      mu = mean(X)';
      Sigma = cov(X);
      if estimateDof, dof = 10; end % start with large dof near Gaussian
   else
      mu = randn(D,1);
      Sigma = diag(rand(D,1)); 
      if estimateDof, dof = ceil(rand(1,1))*5; end
   end
   if verbose, fprintf('starting trial %d of %d\n', trial, ntrials); end 
   [saveMu(:,trial), saveSigma(:,:,trial), saveDof(trial), ...
     loglik(trial), niter(trial)] = doEM(X, mu, Sigma, dof,...
     estimateDof, useECME, useSpeedup);
end

if verbose
  fprintf('final loglik over trials\n');
  disp(loglik)
end

best = argmax(loglik);
mu = saveMu(:,best);
Sigma = saveSigma(:,:,best);
if estimateDof, dof = saveDof(best); end
iter = niter(best);

model = studentDist(mu, Sigma, dof);
end


function [mu, Sigma, dof, ll, iter] =  doEM(X, mu, Sigma, dof, ...
  estimateDof, useECME, useSpeedup)

iter = 1;
maxIter = 30;
tol = 1e-5;
ll = -inf;
done = false;
[N,D] = size(X);

while ~done
  % E step
  SigmaInv = inv(Sigma);
  XC = bsxfun(@minus,X,rowvec(mu));
  delta =  sum(XC*SigmaInv.*XC,2); %#ok
  w = (dof+D) ./ (dof+delta); % E[tau(i)]
  if useSpeedup
    % see McLachlan and Krishnan eqn 5.97-5.98
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
  
  if estimateDof
    if useECME
      dof = estimateDofNLL(X, mu, Sigma, dof);
    else
      dof = estimateDofQ(X, mu, Sigma, dof);
    end
  end
  
  % Assess convergence
  oldll = ll;
  ll = sum(studentLogprob(studentDist(mu, Sigma, dof), X));
  done = convergenceTest(ll, oldll, tol) || iter>maxIter;
  iter = iter + 1;
end % endwhile

end




function dof = estimateDofQ(X, mu, Sigma, dofOld)
% optimize expected neg log likelihood of complete data
% using constrained gradient optimizer.


[N,D] = size(X);
% re-do E step to get multicycle ECM algorithm
SigmaInv = inv(Sigma);
XC = bsxfun(@minus,X,rowvec(mu));
delta =  sum(XC*SigmaInv.*XC,2); %#ok
w = (dofOld+D) ./ (dofOld+delta); % E[u(i)]

dofMax = 1000; dofMin = 0.1;

% use gradient free optimizatin
Qfn = @(v) -N*gammaln(v/2)+N*v*0.5*log(v/2) ...
  + (N*v/2)*((1/N)*sum(log(w)-w)  + ...
  psi((dofOld+D)/2)-log((dofOld+D)/2));
negQfn = @(v) -Qfn(v);
dof = fminbnd(negQfn, dofMin, dofMax);


if 1
  % use gradient based optomization
  utilde = w;
  stilde = log(utilde) + psi((dofOld+D)/2) - log((dofOld+D)/2);
  gradQfn = @(v) (N/2)*(-psi(v/2)+log(v/2)+1)+...
    0.5*sum(stilde - utilde);
  gradNegQfn = @(v) -gradQfn(v);
  % find zero of the gradient by doing a constrained 1d line search
  fn = @(v) fnjoin(v, negQfn, gradNegQfn);
  options.verbose = 0;
  options.numDiff = 0;
  [dof2] = minConF_TMP(fn,dofOld,dofMin,dofMax,options);
  assert(approxeq(dof, dof2, 1e-1))
  %options.display = 'off';
  %options.derivCheck = 1;
  %[dof] = minFunc(fn,dof,options)
end


end


function dof = estimateDofNLL(X, mu, Sigma, dofOld) %#ok
% optimize neg log likelihood of observed data 
% using gradient free optimizer.

[N,D] = size(X);

% use unconstrained optimization
% plug in most recent params to compute NLL
%nllfn = @(v) -sum(studentLogpdf(X, mu, Sigma, v));
nllfn = @(v) -sum(studentLogprob(studentDist(mu, Sigma, v), X));
dofMax = 1000; dofMin = 0.1;
dof = fminbnd(nllfn, dofMin, dofMax);

if 0
  % or use constrained gradient based method
  % eqn 30 from Liu and Rubin 1995 is the gradient of the observed data loglik
  % using the most recent values of mu and Sigma
  % This is not sufficiently much faster to be worth the complexity
  % re-do E step
  SigmaInv = inv(Sigma); %#ok
  XC = bsxfun(@minus,X,rowvec(mu));
  delta =  sum(XC*SigmaInv.*XC,2); % mahalanobis distance
  wfn = @(v) (v+D)./(v+delta);
  gradfn = @(v) -N*(-psi(v/2)+log(v/2)+sum(log(wfn(v))-wfn(v))/N + 1 + ...
    psi((dofOld+D)/2)-log((dofOld+D)/2));
  % find zero of the gradient by doing a 1d line search
  fn = @(v) fnjoin(v, nllfn, gradfn);
  options.verbose = 0;
 
  [dof2] = minConF_TMP(fn,dofOld,dofMin,dofMax,options);
  assert(approxeq(dof, dof2))
end

end
