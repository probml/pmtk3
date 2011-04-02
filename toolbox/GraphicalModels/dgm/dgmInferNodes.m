function [nodeBels, logZ, nodeBelArray] = dgmInferNodes(dgm, varargin)
%% Return all node beliefs (single marginals)
%% Inputs
%
% dgm    - a struct created by dgmCreate
%
%% Optional named inputs
%
% 'clamped'  - a sparse vector of size 1-by-nnodes.
%              clamped(t) = j means node t is clamped to state j
%              clamped(t) = 0 means node t is not clamped
%
% 'softev'   - softev(j, t) = p(v(t) | h(t) = j) where h(t) is
%              the t'th hidden node, and v(t) is its private evidence child.
%              softev can be  created by  mkSoftEvidence.
%              Use NaN columns for nodes without soft
%              evidence, and pad the ends of columns with NaNs for nodes
%              with nstates < max(nstates). softev is
%              max(nstates)-by-nnodes.
%
% 'localev'  - a d-by-nnodes matrix representing a (usually continuous)
%              observation sequence v(:,1:T), which will be converted to factors
%              using localCPDs specified to dgmCreate. Use NaNs for
%              unobserved nodes.
%
% * you can specify both softev and localev
%% Outputs
%
% nodeBels   - a cell array of tabularFactors representing the normalized
%              node beliefs (single marginals).
%             nodeBels{t} is belief for t'th internal node
%
% logZ       - log of the partition sum (if this is all you want, use
%              dgmLogprob)
%
% nodeBelArray(:,v) is the belief state for v'th external node 
%              This has size max(nstates) * Nnodes
%%

% This file is from pmtk3.googlecode.com

[clamped, doSlice, args]  = process_options(varargin, 'clamped', [], 'doSlice', false); %#ok
visVars          = find(clamped);
hidVars          = setdiffPMTK(1:dgm.nnodes, visVars);
[nodeBels, logZ] = dgmInferQuery(dgm, num2cell(hidVars), 'doSlice', doSlice, varargin{:});

if doSlice
    nodeBels  = insertUnitBels(nodeBels, visVars, hidVars);
else
    nodeBels = insertClampedBels(nodeBels, visVars, hidVars, dgm.nstates, clamped);
end

%nodeBelArray = tfMarg2Mat(nodeBels);
% Internal and extneral node numbering may differ
nodeBelArray = zeros(max(dgm.nstates), dgm.nnodes);
for v=1:dgm.nnodes
  t = dgm.invtoporder(v);
  nodeBelArray(1:dgm.nstates(t), v) = nodeBels{t}.T;
end


end
