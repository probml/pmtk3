function [nodeBels, logZ] = dgmInferNodes(dgm, varargin)
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
%
% logZ       - log of the partition sum (if this is all you want, use
%              dgmLogprob)
%
%%
[clamped, args]  = process_options(varargin, 'clamped', []); %#ok
visVars          = find(clamped);
hidVars          = setdiffPMTK(1:dgm.nnodes, visVars);
[nodeBels, logZ] = dgmInferQuery(dgm, num2cell(hidVars), varargin{:});
nodeBels         = insertClampedBels(nodeBels, visVars, hidVars);
end