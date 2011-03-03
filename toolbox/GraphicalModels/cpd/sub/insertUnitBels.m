function padded = insertUnitBels(nodeBels, visVars, hidVars)
% We insert unit factors for the clamped vars to maintain a one-to-one
% corresponence between cell array position and domain, and to return
% consistent results regardless of the inference method.

% This file is from pmtk3.googlecode.com

if isempty(visVars)
    padded = nodeBels;
    return;
end
nvars = numel(visVars) + numel(hidVars);
padded = cell(nvars, 1);
if numel(nodeBels) == nvars
    padded(hidVars) = nodeBels(hidVars);
elseif numel(nodeBels) == 1
    padded{hidVars} = cellwrap(nodeBels); 
else
    padded(hidVars) = nodeBels;
end

for v = visVars
    padded{v} = tabularFactorCreate(1, v);
end

end
