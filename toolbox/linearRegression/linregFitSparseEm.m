function [w, sigma, logpostTrace]=linregFitSparseEm(X, y,  prior,  varargin)
% Use EM to fit linear  regression  with sparsity promoting prior
% See the paper "Sparse Bayesian nonparametric regression"
% by F. Caron and A. Doucet, ICML2008.
% See also "Alternative prior distributions for variable selection
% with very many more variables than observations", Griffin and Brown, 2005
%
% The prior on each regresson weight is 
% p(w) = int N(w|0,tau) Gamma(tau | shape, scale) dtau
% This is a Normal-Gamma distribution.
% If shape=1, this induces a Laplace distribuiton
% If shape=scale=0, this induces Normal-Jeffreys distribution
%
%
% X: N*D design matrix 
% y:        data (vector of size N*1),
% prior: one of 'ng','laplace','nj','neg', 'groupLasso', 'groupNG'
%
% Optional args
% maxIter - [300]
% verbose - [false]
% scale
% shape
% lambda
% sigma: if +ve, it is fixed at this value, if 0 it will be estimated
% groups: a vector of length D specifying group membership (for group
% lasso)
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
%PMTKmodified Kevin Murphy, Hannes Bretschneider


warning off MATLAB:log:logOfZero
warning off MATLAB:divideByZero

[shape, scale, lambda, maxIter, verbose, convTol, sigma, groups] = process_options(varargin, ...
   'shape', [], 'scale', [], 'lambda', [], ...
   'maxIter', 100, 'verbose', false, 'convTol', 1e-3, 'sigma', 1, 'groups', []);

 
[N D]=size(X);
if sigma<0
   % sigma estimated
   computeSigma=1;
   sigma=-sigma;
else % sigma known
   computeSigma=0;
end

if ~isempty(groups)
  nGroups = max(groups);
  groupSize = arrayfun(@(i)sum(groups == i), 1:nGroups);
  shapeGroup = (groupSize + 1)/2; % shape for groups 1:nGroups
  shapeFeat = shapeGroup(groups); % shape for features 1:D
end

switch(lower(prior))
  case 'ridge'
    % no EM required - this is provided to simplify
    % comparisons with the other methods (see linregSparseEmSynthDemo)
    w = linregFitL2QR(X, y, scale);
    sigma = mean((X*w - y).^2);
    logpostTrace = [];
    return;
  case 'ng'
    pen=@normalGammaNeglogpdf;
    diffpen=@normalGammaNeglogpdfDeriv;
    params = {shape, scale};
  case 'laplace'
    pen=@laplaceNeglogpdf;
    diffpen=@laplaceNeglogpdfDeriv;
    params = {lambda}; % user specifies laplace param, not gamma param
  case 'nj'
    pen=@normalJeffreysNeglogpdf;
    diffpen=@normalJeffreysNeglogpdfDeriv;
    params = {};
  case 'neg'
    pen=@normalExpGammaNeglogpdf;
    diffpen=@normalExpGammaNeglogpdfDeriv;
    params = {shape, scale};
  case {'grouplasso', 'gng'}
    scale = lambda^2/2;
     pen=@normalGammaNeglogpdf;
    diffpen=@normalGammaNeglogpdfDeriv;
    params = {colvec(shapeFeat), scale};
  otherwise
    error(['unrecognized prior ' prior])
end

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

if 1 % strcmp(model,'laplace') 
   computeLogpost = true;
else
   % cannot do it for normal gamma because prior is improper?
   computeLogpost = false;
end


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
if verbose
  str = sprintf('EM with %s, scale %5.3f, shape %5.3f', prior, scale, shape);
  disp(str);
end
while ~done
  wOld = w;
  sigmaOld = sigma;
  % E step
  switch prior
    case 'groupLasso'
      wNormGroup = arrayfun(@(i)twoNormGroup(wOld,groups,i), 1:nGroups);
      wNormFeat = wNormGroup(groups);
      psi = diag(wNormFeat./(lambda*sigma));
    case 'gng'
      wNormGroup = arrayfun(@(i)twoNormGroup(wOld,groups,i), 1:nGroups);
      wNormFeat = colvec(wNormGroup(groups));
      psi=diag(wNormFeat./diffpen(wNormFeat,params{:}));
    otherwise
    psi=diag(abs(wOld)./diffpen(wOld,params{:}));
  end
  % M step
  w = psi*V*inv((V'*psi*V+sigma^2*Si2))*alpha_hat;
  yhat = X*w;
  se = (y-yhat).^2;
  if computeSigma
    sigma = sqrt(mean(var(se)));
    sigma = max(sigma, 1e-2); % hack to prevent sigma getting too small
  end
  
  if computeLogpost
    NLL(iter)=N/2*log(sigma^2)+ sum(se)/(2*sigma^2) + sum(pen(w,params{:}));
    if iter>1
      delta = NLL(iter) - NLL(iter-1);
      if delta > 0 && ~approxeq(NLL(iter), NLL(iter-1))
        warning(sprintf(' NLL went from %8.5f to %8.5f (should decrease)\n', ...
          NLL(iter-1), NLL(iter)))
      end
    end
  end
  if verbose &&(mod(iter,1)==0)
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

NLL = NLL(~isinf(NLL));
logpostTrace = -NLL;
if 0 % verbose
  figure; plot(logpostTrace, 'o-'); title(str)
end

end

 
function out=twoNormGroup(w, groups, i)
% Computes the two-norm of the weights in group i
w = w(groups==i);
out = sqrt(sum(w.^2));
end




