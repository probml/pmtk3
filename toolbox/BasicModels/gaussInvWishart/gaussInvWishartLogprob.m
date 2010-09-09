function logp = gaussInvWishartLogprob(arg1, arg2, arg3, arg4, arg5, arg6)
% logp(i) = p(m(:, i), S(:, :, i) | model) 
% logp = gaussInvWishartLogprob(model, m, S) OR
% logp = gaussInvWishartLogprob(mu, Sigma, dof, k, m, S)
%
% logp(i) = p(m(:, i), S(:, :, i) | model) 
%         = N(m(:, i) | model.mu, (1/model.k) * S(:, :, i)) *
%           IW(S(:, :, i) | model.dof, model.Sigma)
%
%                   OR if scalar
% 
% logp(i) = p(m(i), S(i) | model) 
%         = N(m(i)  | model.mu, (1/model.k) * S(i)) *
%           IW(S(i) | model.dof, model.Sigma)
%
%
% model has the following fields: mu, Sigma, dof, k
%
% *** Vectorized w.r.t. to both m and S ***  
%%

% This file is from pmtk3.googlecode.com


if isstruct(arg1)
    model = arg1;
    m = arg2;
    S = arg3;
    mu    = model.mu;
    Sigma = model.Sigma;
    dof   = model.dof;
    k     = model.k;
else
    mu = arg1;
    Sigma = arg2;
    dof = arg3;
    k = arg4;
    m = arg5;
    S = arg6;
end



d     = min(size(S, 1), size(S, 2));  % take care of 1d vectorized case
m     = reshape(m, d, []);
S     = reshape(S, d, d, []); 
n     = max(size(m, 2), size(S, 3)); 
if size(m, 2) < n, m = repmat(m, 1, n); end
if size(S, 3) < n, S = repmat(S, [1, 1, n]); end

pgauss = zeros(n, 1);
gaussModel.mu = mu; 
for i=1:n
   gaussModel.Sigma = S(:, :, i) ./ k; 
   pgauss(i) = gaussLogprob(gaussModel, m(:, i)'); 
end

iwModel.Sigma = Sigma; 
iwModel.dof   = dof; 
piw = invWishartLogprob(iwModel, S);

logp = pgauss + piw;

end
