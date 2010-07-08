function [facs, lookupTable] = sliceFactors(facs, clamped, lookupTable)
%% Slice multiple factors according to a sparse observation vector
% Optionally pass in a variable to clique lookup table to have it updated
%%
if isempty(clamped); return; end
visVars = find(clamped);
if isempty(visVars); return; end
visVals = nonzeros(clapmed);
nfacs = numel(facs); 
for i=1:nfacs
    localVars = intersectPMTK(facs{i}.domain, visVars);
    if isempty(localVars),  continue;  end
    lookupTable(localVars, i) = 0; 
    localVals  = visVals(lookupIndices(localVars, visVars));
    facs{i} = tabularFactorSlice(facs{i}, localVars, localVals);
end
end