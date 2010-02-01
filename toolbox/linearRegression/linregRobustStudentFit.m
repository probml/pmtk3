function model = linregRobustStudentFit(X, y, dof, includeOffset)
% gradient-based optimization of linear regression with Student T noise model
% We assume X is an N*D matrix; we will add a column of 1s internally.
% Set dof=[] (or omit it) if it is unknown.
% model is a structure containing fields: w, dof, sigma2
% where w = [w0 w1 ... wD] is a column vector, where w0 is the bias
 
if nargin < 3 || (dof<=0), dof = []; end
fixedDof = dof;
if nargin < 4, includeOffset = true; end
[N,D] = size(X);
if includeOffset
   X1 = [ones(N,1) X];
end

wLS = X1 \ y; % initialize with least squares
sigma2Init = 1; %iqr(y);
options.Display = 'none';
if isempty(fixedDof)
  dofInit = 1;
  params0 = [dofInit; sigma2Init; wLS];
else
  params0 = [ sigma2Init; wLS];
end
params = minFunc(@StudentLoss, params0, options, X1, y, fixedDof);

if isempty(fixedDof)
  model.dof = params(1);
  model.sigma2 = params(2);
  model.w = params(3:end);
else
  model.dof = fixedDof;
  model.sigma2 = params(1);
  model.w = params(2:end);
end

model.includeOffset = includeOffset;

end

function [nll, g] = StudentLoss(params, X, y, fixedDof)
[N,D] = size(X);
if isempty(fixedDof)
  dof = params(1);
  sigma2 = params(2);
  w = params(3:end);
else
  dof = fixedDof;
  sigma2 = params(1);
  w = params(2:end);
end
sigma = sqrt(sigma2);
dof12 = (dof+1)/2;
logZ = gammaln(dof/2) - gammaln( dof12 ) + 0.5*(log(dof)+log(pi))+log(sigma);
delta = (y-X*w);
delta2 = delta.^2;
nll = N*logZ + sum(dof12  * log(dof*sigma2 + delta2) - log(dof*sigma2));

if nargout >= 1
  numer =  (dof+1)*X.*repmat(delta(:),1,D);
  denom = dof*sigma2 + delta2(:);
  gw = -sum(numer./repmat(denom,1,D), 1)';
  % debug
  if 1
    tmp = zeros(1,D);
    for i=1:N
      tmp = tmp - (dof+1)*delta(i)*X(i,:) ./ (dof*sigma2 + delta(i)^2);
    end
    assert(approxeq(gw, tmp'))
  end
  
  gsigma2 = N/(2*sigma2) + sum(dof12 * (dof./(dof*sigma2 + delta2) - 1/sigma2));
  
  gnu = (N/2)*(digamma(dof/2) - digamma(dof12) + 1/dof) ...
    + sum(0.5*(log(dof*sigma2 + delta2) - log(dof*sigma2)) ...
    + dof12*( sigma2./(dof*sigma2+delta2) - (1/dof)) );
 
  if isempty(fixedDof)
    g = [gnu; gsigma2; gw];
  else
    g = [gsigma2; gw];
  end
end
end


function y = digamma(x)
y = psi(x);
end
