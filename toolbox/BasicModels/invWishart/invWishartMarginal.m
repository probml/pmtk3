function Mq = invWishartMarginal(model, query)
% If M ~ IW(dof,S), then M(q,q) ~ IW(dof-2d+2q, S(q,q))
% Press (2005) p118

% This file is from pmtk3.googlecode.com

q = length(query); 
d = length(model.mu); 
v = model.dof;
Mq.dof = v-2*d+2*q;
Mq.Sigma = model.Sigma(query, query); 
end
