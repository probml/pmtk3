function fg2 = factorGraphMakePairwise(fg)
%% Convert a factorGraph to an equivalent one with only pairwise edge pots
%  
%
% For every unary factor (with just one variable attached), create a local
% evidence node encoding the factor. For every multiway factor, create a
% new mega node whose state-space is the Cartesian product of all the
% variables participating in this factor; create a dummy evidence node
% encoding the factor; create edges between the mega-node and its
% constituent parts; and set the edge potentials such that they enforce
% consistency between the assignment to the mega-node and the values of the
% parts.
%%
if fg.isPairwise
    fg2 = fg;
    return;
end
%% construct megaNodes for each multiway factor
initFactors = fg.factors;
nInitNodes  = numel(fg.round); 
sz          = cellfun(@(f)numel(f.domain), initFactors); 
multiway    = find(sz > 2); 
nMega       = numel(multiway); 
megaNodes   = cell(nMega, 1);
megaIds     = nInitNodes+1:nInitNodes+nMega;
for i=1:nMega
    megaNodes{i} = tabularFactorToMegaNode(initFactors{multiway(i)}, megaIds(i));
end
newFactors = [initFactors(sz <= 2); megaNodes];
%% construct new edge factors between megaNodes and their constituent parts
newEdgeFactors = cell(sum(sz(multiway)), 1); 
counter = 1; 
for i=1:nMega
    mfac = megaNodes{i};
    ifac = initFactors{multiway(i)}; 
    for j=1:numel(ifac.domain)
        
        
        ndom  = [ifac.domain(j), mfac.domain];
        Tedge = zeros(ifac.sizes(j), mfac.sizes); 
        mfac.stateMap
        
        %Tedge(i, j) = 1 if mfac.stateMap(j, 
        
        
        newEdgeFactors{counter} = tabularFactorCreate(Tedge, ndom); 
        counter = counter + 1; 
    end
    
    
end


newFactors = [newFactors; newEdgeFactors]; 
newNstates = [nstates; cellfun(@(f)f.sizes(end), megaNodes)]; 
fg2 = factorGraphCreate(newFactors, newNstates); 







end