function logp = invWishartLogprob(arg1, arg2, arg3)
% logp(i) = log p(S(:, :, i) | model)
% If model.Sigma is scalar, than logp(i) = log p(S(i) | model)
%
% model has fields Sigma and dof
% model.dof must be > d-1
%
% logp = invWishartLogprob(model, S); OR
% logp = invWishartLogprob(Sigma, dof, S);
%%

% This file is from pmtk3.googlecode.com


if isstruct(arg1)
    model = arg1;
    Sigma = model.Sigma;
    dof   = model.dof;
    S     = arg2;
else
    Sigma = arg1;
    dof   = arg2;
    S     = arg3;
end

d     = size(Sigma, 1);
S     = reshape(S, d, d, []);
n     = size(S, 3);
logZ  = (dof*d/2)*log(2) + mvtGammaln(d, dof/2) - (dof/2)*logdet(Sigma);
logp  = zeros(n, 1);
for i=1:n
    logp(i) = - (dof + d+1) / 2*logdet(S(:, :, i)) ...
        - 0.5*trace(Sigma / S(:, :, i))      ...
        - logZ;
end



end
