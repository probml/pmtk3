function S = invWishartSample(model, n)
% S(:, :, 1:n) ~ IW(model.Sigma, model.dof)

if nargin < 2, n = 1; end
Sigma = model.Sigma;
dof   = model.dof;
d     = size(Sigma, 1);
C     = chol(Sigma)';
S     = zeros(d, d, n);
for i=1:n
    Z = randn(dof, d);
    [Q, R] = qr(Z, 0);
    M = C / R;
    S(:, :, i) = M*M';
end
end

