function S = invWishartSample(model, n)
% S(:, :, 1:n) ~ IW(model.Sigma, model.dof)

% This file is from pmtk3.googlecode.com

if nargin < 2, n = 1; end
Sigma = model.Sigma;
dof   = model.dof;
d     = size(Sigma, 1);
C     = chol(Sigma)';
S     = zeros(d, d, n);
for i=1:n
    if (dof <= 81+d) && (dof==round(dof))
        Z = randn(dof, d);
    else
        Z = diag(sqrt(2.*randgamma((dof-(0:d-1))./2)));
        Z(utri(d)) = randn(d*(d-1)/2, 1);
    end
    [Q, R] = qr(Z, 0);
    M = C / R;
    S(:, :, i) = M*M';
end
end

