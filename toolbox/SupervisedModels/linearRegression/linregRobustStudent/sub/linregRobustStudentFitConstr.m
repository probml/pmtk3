function model = linregRobustStudentFitConstr(X, y, dof, sigma2, includeOffset)
% Constrained gradient-based optimization of linear regression with Student T noise model
% We assume X is an N*D matrix; we will optionall add a column of 1s internally.
% Set dof=[] or 0 (or omit it) if it is unknown.
% Set sigma2=[] or 0 (or omit it) if is unknown.
% model is a structure containing fields: w, dof, sigma2
% where w = [w0 w1 ... wD] is a column vector, where w0 is the bias

% This file is from pmtk3.googlecode.com


%PMTKauthor Hannes Bretschneider
%PMTKmodified Kevin Murphy

if nargin < 3 || isempty(dof) || (dof==0), dof = []; end
if nargin < 4 || isempty(sigma2) || (sigma2==0), sigma2 = []; end
if nargin < 5, includeOffset = true; end
[N,D] = size(X);
if includeOffset
   X = [ones(N,1) X];
   D1 = D+1;
else
  D1 = D;
end

if ~isempty(dof) && ~isempty(sigma2)
  % unnconstrained optimization of w with dof and s2 fixed
    options.display = 'none';
    w0  = zeros(D1,1);
    objFun = @(w)StudentLoss(w, X, y, dof, sigma2);
    w = minFunc(objFun, w0, options);
    model = struct('w', w(1:D1), 'sigma2', sigma2, 'dof', dof);
elseif isempty(dof) && isempty(sigma2)
  % constrained opt of all params
    options = optimset('GradObj', 'on', 'display', 'off');
    objFun = @(w)StudentLoss(w, X, y);
    w0 = X\y;
    sigma2_0 = var(y-X*w0);
    dof_0 = 4;
    w0 = [w0; sigma2_0; dof_0];
    lb = [-inf*ones(D1,1); 0; 0];
    ub = inf*ones(D1+2,1);
    w = fmincon(objFun, w0, [], [], [], [], lb, ub, [], options);
    model = struct('w', w(1:D1), 'sigma2', w(D1+1), 'dof', w(D1+2));
elseif isempty(sigma2) && ~isempty(dof)
  % constrained opt of w and sigma2 with dof fixed
  options = optimset('GradObj', 'on', 'display', 'off');
  objFun = @(w)StudentLoss(w, X, y, dof);
  w0 = X\y;
  sigma2_0 = var(y-X*w0);
  w0 = [w0; sigma2_0];
  lb = [-inf*ones(D1,1); 0];
  ub = inf*ones(D1+1,1);
  w = fmincon(objFun, w0, [], [], [], [], lb, ub, [], options);
  model = struct('w', w(1:D1), 'sigma2', w(D1+1), 'dof', dof);
else
  error('cannot fix sigma2 but optimize dof')
end
model.includeOffset = includeOffset;
if includeOffset
    model.w0 = model.w(1);
    model.w(1) = [];
end

end

%%%%%%%%


function [ nll, g ] = StudentLoss( params, x, y, dof, sigma2 )

[n d] = size(x);
switch nargin
  case 3, w = params(1:d); sigma2 = params(d+1); dof = params(d+2);
  case 4,  w = params(1:d);  sigma2 = params(d+1);
  case 5,  w = params(1:d);  
  otherwise, error('bad num args')
end

sigma = sqrt(sigma2);
theta = y - x*w;

nll = sum(1/2*log(dof*pi) + log(gamma(dof/2)) - log(gamma((dof+1)/2)) + ...
    log(sigma) + (dof+1)/2*log(1+theta.^2 / (sigma2*dof)));
g_w = -x'*((dof+1)*theta./(sigma2*dof + theta.^2));

g_dof = sum(1/(2*dof) + 1/2*psi(dof/2) - 1/2*psi((dof+1)/2) +...
  1/2*log(1+(theta.^2)/(sigma2*dof)) - ((dof+1)*theta.^2)./...
  (2*dof*(sigma2*dof+theta.^2)));

g_sigma2 = sum(1/(2*sigma2) - ((dof+1)*theta.^2)./(2*sigma2*...
  (sigma2*dof+theta.^2)));
      
switch nargin
  case 3, g = [g_w; g_sigma2; g_dof];
  case 4, g = [g_w; g_sigma2];
  case 5, g = [g_w];
end
    
end

