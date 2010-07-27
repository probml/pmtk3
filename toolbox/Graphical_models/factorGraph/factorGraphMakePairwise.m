function fg2 = factorGraphMakePairwise(fg)
%% Convert a factorGraph to an equivalent one with only pairwise edge pots
%  
%
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
stateMaps   = cell(nMega, 1); 
for m=1:nMega
    [megaNodes{m}, stateMaps{m}] = tabularFactorToMegaNode(initFactors{multiway(m)}, megaIds(m));
end
newFactors = [initFactors(sz <= 2); megaNodes];
%% construct new edge factors between megaNodes and their constituent parts
newEdgeFactors = cell(sum(sz(multiway)), 1); 
counter = 1; 
for m = 1:nMega
    mfac      = megaNodes{m};
    ifac      = initFactors{multiway(m)}; 
    ifacDom   = ifac.domain;
    mfacDom   = mfac.domain; 
    ifacSizes = ifac.sizes;
    mfacSizes = mfac.sizes; 
    for i = 1:numel(ifacDom)
        newdom   = [ifacDom(i), mfacDom];
        stateMap = stateMaps{m}; 
        Tedge    = zeros(ifacSizes(i), mfacSizes); 
        for k=1:ifacSizes(i)
            Tedge(k, :) = rowvec(stateMap(:, i) == k);
        end
        newEdgeFactors{counter} = tabularFactorCreate(Tedge, newdom); 
        counter = counter + 1; 
    end
end

newNstates = [fg.nstates; cellfun(@(f)f.sizes(end), megaNodes)]; 


newFactors = [newFactors; newEdgeFactors]; 
fg2        = factorGraphCreate(newFactors, newNstates); 
end