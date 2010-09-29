function padded = insertClampedBels(nodeBels, visVars, hidVars, nstates, clamped)
%% Insert clamped belief nodes. 
% Similar to insertUnitBels, but we do not slice the observed node down to 
% a unit factor, we just clamp it to its observed value. 

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
    T = zeros(nstates(v), 1); 
    T(clamped(v)) = 1;
    padded{v} = tabularFactorCreate(T, v);
end
end
