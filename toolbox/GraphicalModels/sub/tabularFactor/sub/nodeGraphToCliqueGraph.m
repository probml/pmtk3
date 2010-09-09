function Gfull = nodeGraphToCliqueGraph(G, Tfac)
%% Expand a node graph into a clique graph
% We assume that the input G is the node toplogy, that the first 
% size(G, 1) factors in Tfac are node factors, and that the remaining
% factors are edge factors. 
%%

% This file is from pmtk3.googlecode.com

G = mkSymmetric(G); 
nfacs = numel(Tfac); 
nvars = size(G, 1); 
Gfull = zeros(nfacs, nfacs); 
Gfull(1:nvars, 1:nvars) = G; 
edgeFacs = Tfac(nvars+1:end); 
for i=1:numel(edgeFacs)
    fac = edgeFacs{i}; 
    j = nvars+i;
    dom = fac.domain; 
    Gfull(j, dom) = 1; 
    Gfull(dom, j) = 1; 
end
end
