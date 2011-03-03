function facs = addEvidenceToFactors(facs, evidence, doSlice)
%% Slice (or clamp) multiple factors according to a sparse observation vector
%

% This file is from pmtk3.googlecode.com

if nargin < 3, doSlice = true; end
if doSlice
    fn = @tabularFactorSlice;
else
    fn = @tabularFactorClamp;
end

if isempty(evidence); return; end
visVars = find(evidence);
if isempty(visVars); return; end
visVals = nonzeros(evidence);
nfacs = numel(facs); 
for i=1:nfacs
    localVars = intersectPMTK(facs{i}.domain, visVars);
    if isempty(localVars),  continue;  end
    localVals  = visVals(lookupIndices(localVars, visVars));
    facs{i} = fn(facs{i}, localVars, localVals);
end
end
