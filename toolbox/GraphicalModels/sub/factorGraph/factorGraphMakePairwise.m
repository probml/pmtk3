function fg2 = factorGraphMakePairwise(fg)
%% Convert a factorGraph to an equivalent one with only pairwise edge pots
%  
%
%%

% This file is from pmtk3.googlecode.com

if fg.isPairwise
    fg2 = fg;
    return;
end

nstates = fg.nstates;
%% construct megaNodes for each multiway factor
initFactors = colvec(fg.factors);
nInitNodes  = numel(fg.round); 
sz          = cellfun(@(f)numel(f.domain), initFactors); 
multiway    = find(sz > 2); 
nMega       = numel(multiway); 
megaNodes   = cell(nMega, 1);
megaIds     = nInitNodes+1:nInitNodes+nMega;
stateMaps   = cell(nMega, 1); 
for m=1:nMega
    [megaNodes{m}, stateMaps{m}] = ...
        tabularFactorToMegaNode(initFactors{multiway(m)}, megaIds(m));
end
%% construct dummy evidence nodes
singletons = cellfun(@(f)f.domain, initFactors(sz == 1));
dummyNeeded = setdiffPMTK(1:numel(nstates), singletons); 
dummyNodes = cell(numel(dummyNeeded), 1);
for i=1:numel(dummyNeeded)
    j = dummyNeeded(i); 
   dummyNodes{i} = tabularFactorCreate(ones(nstates(j), 1), j);  
end
newFactors = [initFactors(sz <= 2); megaNodes; dummyNodes];
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

newNstates = [nstates; cellfun(@(f)f.sizes(end), megaNodes)]; 
newFactors = [newFactors; newEdgeFactors]; 
fg2        = factorGraphCreate(newFactors, newNstates); 
end
