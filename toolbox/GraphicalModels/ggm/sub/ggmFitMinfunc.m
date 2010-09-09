function P = ggmFitMinfunc(G, X, C)
% MLE for a GGM using gradient method
% Usage:
% precMat = ggmFitMinfunc(G, X) % X is N*D
% or precMat = ggmFitMinfunc(G, [], C) % C is cov(X) D*D

% This file is from pmtk3.googlecode.com


%PMTKauthor Mark Schmidt
%
% Basically the same code as GWishartFit, except we use the 
% unregularized cov mat

if nargin < 3
  C = cov(X,1);
end
p = size(C,1);


%Find non-zero elements of upper triangle of G
%make sure diagonal is non-zero
nonZero = triu((eye(p)+G)>0);
nonZero = nonZero(:);

%Set minfunc options
options.TolX            = 1e-16;           
options.TolFun          = 1e-16;
options.Method          = 'lbfgs';
options.MaxFunEvals     = 5000;
options.MaxIter         = 5000;    
options.DerivativeCheck = 'off';
options.Display         = 'off';

%Define the objective function, run the optimizer and get the results
P0         = eye(p);
lambda     = 0;
funObj     = @(x)sparsePrecisionObjLambda(x,p,nonZero,C,lambda);
[Ptmp,f]   = minFunc(funObj,P0(nonZero),options);
P          = zeros(p);
P(nonZero) = Ptmp;
P          = P + triu(P,1)';

end

function [f,g] = sparsePrecisionObjLambda(x,p,nonZero,C,lambda)

%Description: This function compute the objective and gradient for
%  the MLE of the precision matrix given emperical covariance matrix C
%  and list of non-zero upper triangle precision matrix entries given by
%  nonZero. lambda is an l2 regularizer on the precision matrix entries. 
%  Based on sparse GGM estimation code by Mark Schmidt.
% Revision History:
%   Benjamin Marlin   06/21/2010

  X = zeros(p);  %initialize X to zeros
  X(nonZero) = x;    %fill the diagonal and upper triangle
  X = X + triu(X,1)';%fill the lower triangle

  %compute cholesky factorization to check if current precision matrix
  %is positive definite
  [R,posdefind] = chol(X); 

  if(posdefind == 0)
      % Matrix is in positive-definite cone
      % Fast Way to compute -logdet(X) + tr(X*C)
      f = -2*sum(log(diag(R))) + sum(sum(C.*X)) + (lambda/2)*sum(X(:).^2);
      if(nargout>1)
        g = -inv(X) + C + lambda*X; %compute gradient
        g = g + tril(g,-1)'; %add contribution from lower triangle to upper triangle
        g = g(nonZero); %retain diagonal and upper triangle only
      end
  else
      % Matrix not in positive-definite cone, set f to Inf
      % to force minFunc to backtrack
      f = inf;
      g = 0;
  end

end
