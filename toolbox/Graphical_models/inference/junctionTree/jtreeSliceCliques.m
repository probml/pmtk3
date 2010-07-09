function jtree = jtreeSliceCliques(jtree, clamped)
%% Slice cliques in a jtree according to the sparse evidence vector clamped

if isempty(clamped); return; end
visVars = find(clamped);
if isempty(visVars); return; end
visVals = nonzeros(clamped);
cliques      = jtree.cliques; 
cliqueLookup = jtree.cliqueLookup;
for i=1:numel(cliques)
    localVars = intersectPMTK(cliques{i}.domain, visVars);
    if isempty(localVars),  continue;  end
    cliqueLookup(localVars, i) = 0;
    localVals  = visVals(lookupIndices(localVars, visVars));
    cliques{i} = tabularFactorSlice(cliques{i}, localVars, localVals);
end
jtree.cliques      = cliques; 
jtree.cliqueLookup = cliqueLookup; 
end