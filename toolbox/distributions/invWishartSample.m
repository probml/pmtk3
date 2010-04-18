function S = invWishartSample(model, n)
% Return n samples from the inverse Wishart distribution with parameters
% model.Sigma, and model.dof.
%
% The ith sample is S(:, :, i)
%
%%
if nargin < 2, n = 1; end
Sigma = model.Sigma;
dof   = model.dof;
d     = size(Sigma, 1);

C = chol(Sigma);
chi2Model.dof = dof-(0:d-1);

S = zeros(d, d, n);
for i=1:n
    if (dof <= 81+d)
        X = randn(dof, d);
    else
        X = diag(sqrt(chi2Sample(chi2Model,d)))+setdiag(triu(randn(d)), 0);
    end
    [Q, R] = qr(X, 0);
    M = C' / R;
    S(:, :, i) = M*M';
end
end

