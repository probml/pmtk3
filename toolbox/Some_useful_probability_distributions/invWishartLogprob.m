function logp = invWishartLogprob(model, S)
% logp(i) = log p(S(:, :, i) | model)
% If model.Sigma is scalar, than logp(i) = log p(S(i) | model)
%
% model has fields Sigma and dof
% model.dof must be > d-1

Sigma = model.Sigma;
dof   = model.dof;
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