function [nodeBels, logZ, edgeBels] = mrfInferNodes(mrf, varargin)
%% Return all node beliefs (single marginals)
% 
% mrf is a struct as created by mrfCreate
%
% Optional named args are the same as for dgmInferNodes
%
%%

% This file is from pmtk3.googlecode.com

[clamped, doSlice, args]   = process_options(varargin, 'clamped', [], ...
    'doSlice', false); %#ok
visVars           = find(clamped);
hidVars           = setdiffPMTK(1:mrf.nnodes, visVars);
edgeBelsRequested = nargout > 2;
    
query = num2cell(hidVars); 
if edgeBelsRequested
    query = [query(:); mrf.edges(:)]; 
end
[bels, logZ] = mrfInferQuery(mrf, query, 'doSlice', doSlice, varargin{:});
if edgeBelsRequested
    nhid     = numel(hidVars);
    nodeBels = bels(1:nhid);
    edgeBels = bels(nhid+1:end);
else
    nodeBels = bels;
end
if doSlice
    nodeBels = insertUnitBels(nodeBels, visVars, hidVars);
else
    nodeBels = insertClampedBels(nodeBels, visVars, hidVars, mrf.nstates, clamped); 
end
end
