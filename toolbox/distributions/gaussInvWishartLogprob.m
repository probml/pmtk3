function logp = gaussInvWishartLogprob(model, m, S)
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

mu    = model.mu;
Sigma = model.Sigma; 
dof   = model.dof;
k     = model.k;

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
   pgauss(i) = gaussLogprob(gaussModel, m(:, i)); 
end

iwModel.Sigma = Sigma; 
iwModel.dof   = dof; 
piw = invWishartLogprob(iwModel, S);

logZ = (dof*d/2)*log(2) + mvtGammaln(d, dof/2) - ...
       (dof/2)*logdet(Sigma) + (d/2)*log(2*pi/k);
   
logp = pgauss + piw - logZ; 


  
          







end