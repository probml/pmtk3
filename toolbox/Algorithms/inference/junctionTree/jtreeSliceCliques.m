function jtree = jtreeSliceCliques(jtree, clamped, doSlice)
%% Slice cliques in a jtree according to the sparse evidence vector clamped
% You can optionally clamp them instead, (useful for debugging, etc)

% This file is from pmtk3.googlecode.com



if nargin < 3 
    doSlice = false;
end
if doSlice
    evidenceFn = @tabularFactorSlice;
else
    evidenceFn = @tabularFactorClamp; 
end

if isempty(clamped); return; end
visVars = find(clamped);
if isempty(visVars); return; end
visVals = nonzeros(clamped);
cliques      = jtree.cliques; 
cliqueLookup = jtree.cliqueLookup;
for i=1:numel(cliques)
    localVars = intersectPMTK(cliques{i}.domain, visVars);
    if isempty(localVars),  continue;  end
    if doSlice
        cliqueLookup(localVars, i) = 0;
    end
    localVals  = visVals(lookupIndices(localVars, visVars));
    cliques{i} = evidenceFn(cliques{i}, localVars, localVals);
end

jtree.cliques      = cliques; 
jtree.cliqueLookup = cliqueLookup; 
end
