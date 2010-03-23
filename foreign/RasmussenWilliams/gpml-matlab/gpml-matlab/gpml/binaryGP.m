function [out1, out2, out3, out4, alpha, sW, L] = binaryGP(hyper, approx, covfunc, lik, x, y, xstar)

% Approximate binary Gaussian Process classification. Two modes are possible:
% training or testing: if no test cases are supplied, then the approximate
% negative log marginal likelihood and its partial derivatives wrt the
% hyperparameters is computed; this mode is used to fit the hyperparameters. If
% test cases are given, then the test set predictive probabilities are
% returned. Exact inference is intractible, the function uses a specified
% approximation method (see approximations.m), flexible covariance functions
% (see covFunctions.m) and likelihood functions (see likelihoods.m).
%
% usage: [nlZ, dnlZ  ] = binaryGP(hyper, approx, covfunc, lik, x, y);
%    or: [p,mu,s2,nlZ] = binaryGP(hyper, approx, covfunc, lik, x, y, xstar);
%
% where:
%
%   hyper    is a column vector of hyperparameters
%   approx   is a function specifying an approximation method for inference 
%   covfunc  is the name of the covariance function (see below)
%   lik      is the name of the likelihood function
%   x        is a n by D matrix of training inputs
%   y        is a (column) vector (of size n) of binary +1/-1 targets
%   xstar    is a nn by D matrix of test inputs
%   nlZ      is the returned value of the negative log marginal likelihood
%   dnlZ     is a (column) vector of partial derivatives of the negative
%               log marginal likelihood wrt each hyperparameter
%   p        is a (column) vector (of length nn) of predictive probabilities
%   mu       is a (column) vector (of length nn) of predictive latent means
%   s2       is a (column) vector (of length nn) of predictive latent variances
%
% The length of the vector of hyperparameters depends on the covariance
% function, as specified by the "covfunc" input to the function, specifying the
% name of a covariance function. A number of different covariance function are
% implemented, and it is not difficult to add new ones. See covFunctions.m for
% the details.
%
% The "lik" input argument specifies the name of the likelihood function (see
% likelihoods.m).
%
% The "approx" input argument to the function specifies an approximation method
% (see approximations.m). An approximation method returns a representation of
% the approximate Gaussian posterior. Usually, the approximate posterior admits
% the form N(m=K*alpha, V=inv(inv(K)+W)), where alpha is a vector and W is
% diagonal. The approximation method returns:
%
%   alpha    is a (sparse or full column vector) containing inv(K)*m, where K
%               is the prior covariance matrix and m the approx posterior mean
%   sW       is a (sparse or full column) vector containing diagonal of sqrt(W)
%               the approximate posterior covariance matrix is inv(inv(K)+W)
%   L        is a (sparse or full) matrix, L = chol(sW*K*sW+eye(n))
%
% In cases where the approximate posterior variance does not admit the form
% V=inv(inv(K)+W) with diagonal W, L contains instead -inv(K+inv(W)), and sW
% is unused.
%
% The alpha parameter may be sparse. In that case sW and L can either be sparse
% or full (retaining only the non-zero rows and columns, as indicated by the
% sparsity structure of alpha).  The L paramter is allowed to be empty, in
% which case it will be computed.
%
% The function can conveniently be used with the "minimize" function to train
% a Gaussian Process, eg:
%
% [hyper, fX, i] = minimize(hyper, 'binaryGP', length, 'approxEP', 'covSEiso', 'logistic', x, y);
%
% where "length" gives the length of the run: if it is positive, it gives the 
% maximum number of line searches, if negative its absolute gives the maximum 
% allowed number of function evaluations.
%
% Copyright (c) 2007 Carl Edward Rasmussen and Hannes Nickisch, 2007-06-25.

if nargin<6 || nargin>7
  disp('Usage: [nlZ, dnlZ  ] = binaryGP(hyper,approx,covfunc,lik,x,y);')
  disp('   or: [p,mu,s2,nlZ] = binaryGP(hyper,approx,covfunc,lik,x,y,xstar);')
  return
end

if ischar(covfunc), covfunc = cellstr(covfunc); end  % convert to cell if needed
[n, D] = size(x);   Nhyp = eval(feval(covfunc{:}));
if Nhyp ~= size(hyper, 1)
  error('Number of hyperparameters disagrees with covariance function')
end

if numel(approx)==0, approx='approxLA'; end                % set a default value
if numel(lik)==0,    lik   ='cumGauss'; end                % set a default value

try                                              % call the approximation method
  [alpha, sW, L, nlZ, dnlZ] = feval(approx, hyper, covfunc, lik, x, y);
catch
  warning('The approximation did not properly return')           % values to ...
  nlZ=Inf; dnlZ=zeros(Nhyp,1); alpha=sparse(NaN); sW=NaN; L=1;   % ...  continue
end

if nargin==6                           % return negative log marginal likelihood
    
  out1 = nlZ;
  if nargout>1                              % where partial derivates requested?
    out2 = dnlZ; out3=[]; out4=[];
  end
  
else                        % otherwise do prediction based on the approximation
   
  if issparse(alpha)                  % handle things for sparse representations
    nz = alpha ~= 0;                                 % determine nonzero indices
    if issparse(L), L = full(L(nz,nz) ); end     % convert L and sW if necessary
    if issparse(sW), sW = full(sW(nz));  end
  else nz = true(n,1); end                           % non-sparse representation

  if numel(L)==0                      % in case L is not provided, we compute it
    K = feval(covfunc{:},hyper,x(nz,:));
    L = chol(eye(sum(nz))+sW*sW'.*K);
  end
  Ltril =all(all(tril(L,-1)==0)); % determine if L is an upper triangular matrix
  
  out1=[]; out2=[]; out3=[]; out4=nlZ;                   % init output arguments
  nstar   = size(xstar,1);                               % number of data points
  nperchk = 1000;                              % number of data points per chunk
  nact    = 0;                                 % number of processed data points
  while nact<nstar            % process minibatches of test cases to save memory
    id = (nact+1):min(nact+nperchk,nstar);              % data points to process
    
    [kstarstar, kstar] = feval(covfunc{:}, hyper, x(nz,:), xstar(id,:));
    mu = kstar'*full(alpha(nz));                              % predictive means
    if Ltril           % L is triangular => use Cholesky parameters (alpha,sW,L)
      v  = L'\(repmat(sW,1,length(id)).*kstar);
      s2 = kstarstar - sum(v.*v,1)';                      % predictive variances
    else               % L is not triangular => use alternative parameterisation
      s2 = kstarstar + sum(kstar.*(L*kstar),1)';          % predictive variances
    end
    p  = feval(lik, [], mu, s2);                      % predictive probabilities
    
    out1=[out1;p]; out2=[out2;mu]; out3=[out3;s2];     % assign output arguments
    nact = id(end);          % set counter to index of last processed data point
  end  

end
