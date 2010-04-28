function logp = wishartLogprob(model, S)
% logp(i) = log p(S(:, :, i) | model.Sigma, model.dof)

Sigma = model.Sigma;
v = model.dof; 
d = size(Sigma, 1); 
n = size(S, 3); 
logZ = (v*d/2)*log(2) + mvtGammaln(d, v/2) +(v/2)*logdet(Sigma);  
logp = zeros(n, 1); 
for i=1:n
     Si = S(:, :, i); 
     logp(i) = (v-d-1)/2*logdet(Si) - 0.5*trace(Sigma \ Si) - logZ;
end


end