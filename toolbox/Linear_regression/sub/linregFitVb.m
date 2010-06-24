function [model, logev] = linregFitVb(X, y, addOnes, varargin)
% Variational bayes inference for linear regression
% We use the following prior:
%   p(w, beta, alpha) = N(w | 0, (beta diag(alpha))^{-1}) *
%       * IG(beta | a0, b0) * IG(alpha | c0, d0)
% where a0, b0, c0, d0 are set small (vague prior)
% where alpha is a vector of precisions and beta is the noise precision.
% (Thus the model implements ARD) 
% If addOnes=true, we clamp E(alpha(1)) = 10^10 to ensure
% that the first term of w is not regularized.
%
% model is struct  with the following fields
%   wN, VN, aN, bN, cN, dN, expectAlpha, 
%
% logev is the lower bound on the log marginal likelihood

%PMTKauthor Jan Drugowitsch
%PMTKurl http://www.bcs.rochester.edu/people/jdrugowitsch/code.html
%PMTKmodified Kevin Murphy

% KPM mpd
[max_iter] = process_options(varargin, 'maxIter', 100);

% uninformative priors
a0 = 1e-2;
b0 = 1e-4;
c0 = 1e-2;
d0 = 1e-4;

% pre-process data
[N D] = size(X);
X_corr = X' * X;
Xy_corr = X' * y;
an = a0 + N / 2;
cn = c0 + 1 / 2;

% iterate to find hyperparameters
L_last = -realmax;
E_a = ones(D, 1) * c0 / d0;
for iter = 1:max_iter
    % covariance and weight of linear model
    invV = diag(E_a) + X_corr;
    V = inv(invV);
    logdetV = - logdet(invV);
    w = V * Xy_corr;
    % parameters of noise model (an remains constant)
    sse = sum((X * w - y) .^ 2);
    bn = b0 + 0.5 * (sse + sum(w .^ 2 .* E_a));
    E_t = an / bn;
    % hyperparameters of covariance prior (cn remains constant)
    dn = d0 + 0.5 * (E_t .* w .^ 2 + diag(V));
    E_a = cn ./ dn;
    % variational bound
    L = - 0.5 * (E_t * sse + sum(sum(X .* (X * V)))) + 0.5 * logdetV ...
        - b0 * E_t + gammaln(an) - an * log(bn) + an ...
        + D * gammaln(cn) - cn * sum(log(dn));
    % variational bound must grow!
    if L_last > L
        fprintf('Last bound %6.6f, current bound %6.6f\n', L_last, L);
        error('Variational bound should not reduce');
    end
    % stop if change in variation bound is < 0.001%
    if abs(L_last - L) < abs(0.00001 * L)
        break
    end
    L_last = L;    
end


% augment variational bound with constant terms
logev = L - 0.5 * (N * log(2 * pi) - D) - gammaln(a0) + a0 * log(b0) ...
  + D * (- gammaln(c0) + c0 * log(d0));

model.wN  = w; model.VN = V;
model.aN = an; model.bN = bn;
model.cN = cn; model.dN = dn;
model.expectAlpha = E_a;
end
