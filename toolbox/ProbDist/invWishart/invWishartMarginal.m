function Mq = invWishartMarginal(model, query)
% If M ~ IW(dof,S), then M(q,q) ~ IW(dof-2d+2q, S(q,q))
% PMTKsimpleModel invWishart
% Press (2005) p118
q = length(query); 
d = length(model.mu); 
v = model.dof;
Mq.dof = v-2*d+2*q;
Mq.Sigma = model.Sigma(query, query); 
end