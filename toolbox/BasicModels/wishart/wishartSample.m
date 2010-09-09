function S = wishartSample(arg1, arg2, arg3)
% S(:, :, 1:n) ~ Wi(Sigma, dof)
% S = wishartSample(model, n); OR S = wishartSample(Sigma, dof, n);

% This file is from pmtk3.googlecode.com


if isstruct(arg1)
    model = arg1;
    Sigma = model.Sigma;
    dof   = model.dof;
    if nargin < 2,
        n = 1;
    else
        n = arg2;
    end
else
    Sigma = arg1;
    dof   = arg2;
    if nargin < 3
        n = 1;
    else
        n = arg3;
    end
end

d = size(Sigma, 1);
C = chol(Sigma);
S = zeros(d, d, n);
for i=1:n
    Z = randn(dof, d) * C;
    S(:, :, i) = Z'*Z;
end
end
