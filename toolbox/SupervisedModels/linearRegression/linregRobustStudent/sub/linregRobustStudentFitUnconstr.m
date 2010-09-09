function [model] = linregRobustStudentFitUnconstr(X, y, includeOffset)
% Unconstrained optimization of linear regression with student noise model
%PMTKauthor Yi Huang

% This file is from pmtk3.googlecode.com


if nargin < 4
    includeOffset = 1;
end

[N, D] = size(X);
if includeOffset
    X = [ones(N, 1), X];
    D = D + 1;
end

par_init = ones(D + 2, 1);
options_Method  = 'lbfgs';
options.Display = 'none';
params = minFunc(@StudentLoss, par_init, options, X, y);

model.w             = params(1:D);
model.dof            = params(D + 1);
model.sigma2        = params(D + 2);
model.includeOffset = includeOffset;
end

function [nll, g] = StudentLoss(par, X, y)
[N, D] = size(X);
w = par(1:D);
nu = par(D + 1);
sigma2 = par(D + 2);
Xw = X * w;

nll = N * (gammaln(nu / 2) - gammaln((nu + 1) / 2) ...
           - nu / 2 * log(nu) - nu / 2 * log(sigma2)) ...
     + (nu + 1) / 2 * sum(log(nu * sigma2 + (Xw - y).^2));

if nargout > 1
    g = zeros(D + 2, 1);
    p = (Xw - y) ./(nu * sigma2 + (y - Xw).^2) ;
    g(1:D)   = (nu + 1) * X' * p;

    g(D + 1) = N / 2 * (psi(nu / 2) - psi((nu + 1) / 2) ...
                        - log(nu) - log(sigma2) - 1) ...
              + 1 / 2 * sum(log(nu * sigma2 + (Xw - y).^2)) ...
              + sum(((nu + 1) * sigma2) ./ (2 * (nu * sigma2 + (Xw - y).^2)));

    g(D + 2) = - N * nu / (2 * sigma2) ...
               + sum(((nu + 1) * nu) ./ (2 * (nu * sigma2 + (Xw - y).^2)));
end
end

