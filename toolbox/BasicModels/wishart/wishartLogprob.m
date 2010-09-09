function logp = wishartLogprob(arg1, arg2, arg3)
% logp(i) = log p(S(:, :, i) | model.Sigma, model.dof)
% logp = wishartLogprob(model, S); OR logp = wishartLogprob(Sigma, dof, S);
% 

% This file is from pmtk3.googlecode.com

if isstruct(arg1)
    model = arg1; 
    Sigma = model.Sigma; 
    v     = model.dof; 
    S     = arg2; 
else
    Sigma = arg1; 
    v     = arg2; 
    S     = arg3; 
end

d = size(Sigma, 1); 
n = size(S, 3); 
logZ = (v*d/2)*log(2) + mvtGammaln(d, v/2) +(v/2)*logdet(Sigma);  
logp = zeros(n, 1); 
for i=1:n
     Si = S(:, :, i); 
     logp(i) = (v-d-1)/2*logdet(Si) - 0.5*trace(Sigma \ Si) - logZ;
end


end
