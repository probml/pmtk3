function [w, sigma, logpostTrace]=linregFitGroupLassoEm(X, y, groups, scale, sigma, varargin)
% Fits the grouped lasso model

% X: N*D design matrix 
% y:        data (vector of size N*1),
% sigma: if +ve, it is fixed at this value, if 0 it will be estimated
% prior: one of 'ng','laplace','nj','neg'
%
% Optional args
% maxIter - [300]
% verbose - [false]
%
% -- OUTPUTS --
%
% w     MAP estimate of weight vector 
% sigma     MLE of noise std dev
% logpostTrace   Objective vs iteration
% ---------------------------------
% Author: Francois Caron
% University of British Columbia
% Jan 30, 2008

%PMTKauthor Francois Caron
%PMTKmodified Kevin Murphy, 12 Nov 2009
% modified Hannes Bretschneider, 01 Mar 2010

warning off MATLAB:log:logOfZero
warning off MATLAB:divideByZero

[maxIter, verbose, convTol] = process_options(varargin, ...
   'maxIter', 100, 'verbose', false, 'convTol', 1e-3);

if nargin < 5, sigma = -1; end
 
nGroups = max(groups);
groupSize = arrayfun(@(i)sum(groups == i), 1:nGroups); % Get size of each group

[N D]=size(X);
if sigma<0
   % sigma estimated
   computeSigma=1;
   sigma=-sigma;
else % sigma known
   computeSigma=0;
end

% Use Normal-Gamma Prior
pen=@normalGammaNeglogpdf;
diffpen=@normalGammaNeglogpdfDeriv;
gamma = scale^2/2;
shapeGroup = (groupSize + 1)/2; % shape for groups 1:nGroups
shapeFeat = shapeGroup(groups); % shape for features 1:D

% Singular value decomposition to speed code
% - see Griffin and Brown, 2005, for details
[U S V]=svd(X);
ind=find(diag(S)>10^-10);
S=S(ind,ind);
U=U(:,ind);
V=V(:,ind);
Sinv = inv(S);
alpha_hat = Sinv*U'*y;
Si2 = S^-2;

computeLogpost = true;

w = pinv(X)*y;  % initialize from ridge
yhat = X*w;  se = (y-yhat).^2;

if computeSigma,
  fprintf('initializing sigma\n');
  sigma = sqrt(mean(var(se))) % this will overfit because we use 
  % the pinv to initialize w
  sigma = 1;
end

done = false;
iter = 1; 
while ~done
  wOld = w;
  sigmaOld = sigma;
  % E step
  wNormGroup = arrayfun(@(i)twoNormGroup(wOld,groups,i), 1:nGroups);
  wNormFeat = wNormGroup(groups);
  psi = diag(wNormFeat./(gamma*sigma));

  % M step
  w = psi*V*inv((V'*psi*V+sigma^2*Si2))*alpha_hat;
  yhat = X*w;
  se = (y-yhat).^2;
  if computeSigma
    sigma = sqrt(mean(var(se)));
    sigma = max(sigma, 1e-2); % hack to prevent sigma getting too small
  end
  
  if computeLogpost
    peni = arrayfun(@(i)pen(wOld(i),shapeFeat(i),gamma),1:D);
    NLL(iter)=N/2*log(sigma^2)+ sum(se)/(2*sigma^2) + sum(peni);
    
    if iter>1
      delta = NLL(iter) - NLL(iter-1);
      if delta > 0 && ~approxeq(NLL(iter), NLL(iter-1))
        warning(sprintf(' NLL went from %8.5f to %8.5f (should decrease)\n', ...
          NLL(iter-1), NLL(iter)))
      end
    end
  end
  if verbose &&(mod(iter,50)==0)
    if computeLogpost
      fprintf('iter %d, pen NLL = %5.3f\n', iter, NLL(iter))
    else
      fprintf('iter %d\n', iter)
    end
  end
  
  if iter>1
    converged = convergenceTest(NLL(iter), NLL(iter-1), convTol);
  else
    converged = false;
  end
  if isequal(w, wOld) || converged || (iter > maxIter) || isinf(NLL(iter))
    done = true;
    if isinf(NLL(iter))
      w = wOld; % backtrack to previous stable value
      if verbose, fprintf('backtracking from -inf\n'); end
    end
  end
  iter = iter + 1;
end

logpostTrace = -NLL;
if 0 % verbose
  figure; plot(logpostTrace, 'o-'); title(str)
end

warning on MATLAB:log:logOfZero
warning on MATLAB:divideByZero

end

function out=pen_normalgamma(w,shape, scale)
lambda = shape;
gamma = sqrt(2*scale);
warning off
out=(0.5-lambda).*log(abs(w))-log(besselk(lambda-0.5,gamma*abs(w)));
out = out(:,1);
warning on
end

function out=diffpen_normalgamma(w,shape,scale)
lambda = shape;
gamma = sqrt(2*scale);
out=gamma*besselk(lambda-3/2,gamma*abs(w),1)./besselk(lambda-1/2,gamma*abs(w),1);
out = out(:,1);
out(isnan(out))=inf;
end

function out=twoNormGroup(w, groups, i)
% Computes the two-norm of the weights in group i
w = w(groups==i);
out = sqrt(sum(w.^2));
end