function model = mkRndCliqueGraph(nnodes, maxNstates, maxFanIn, maxFanOut)
%% Create a random clique graph

% This file is from pmtk3.googlecode.com


G = mkRndDag(nnodes, maxFanIn, maxFanOut);

Tfac    = cell(nnodes, 1);
nstates = randi(maxNstates-1, nnodes, 1)+1;


for i=1:nnodes
    family = [parents(G, i)  , i];
    sz = rowvec(nstates(family));
    if isscalar(sz)
        sz = [sz, 1];
    end
    T = normalize(rand(sz));
    Tfac{i} = tabularFactorCreate(T, family);
    assert(numel(Tfac{i}.sizes) == numel(Tfac{i}.domain)); 
end



model = structure(G, Tfac);



end
