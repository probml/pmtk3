function S = wishartSample(model, n)
% S(:, :, 1:n) ~ Wi(model.Sigma, model.dof)

if nargin < 2, n = 1; end
Sigma = model.Sigma;
dof   = model.dof; 
d = size(Sigma, 1); 
C = chol(Sigma); 
S = zeros(d, d, n); 
for i=1:n
    Z = randn(dof, d) * C;
    S(:, :, i) = Z'*Z;
end
end