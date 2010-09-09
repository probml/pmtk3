function [familyBels, logZ, nodeBels] = dgmInferFamily(dgm, varargin)
%% Compute the beliefs for the family of every node
% Optional args are the same as for dgmInferQuery
%
% If requested, nodeBels{i} is the ith marginal, if the ith node has a local
% CPD, and empty otherwise, (used by dgmTrainEm).
%%

% This file is from pmtk3.googlecode.com

calcNodeBels = nargout > 2; 
nnodes       = dgm.nnodes; 
queries      = allFamilies(dgm.G);
if calcNodeBels
    nodeBels = cell(nnodes, 1); 
    hasLocalCpd = find(dgm.localCPDpointers); 
    if isempty(hasLocalCpd)
        calcNodeBels = false;
    else
        queries = [queries(:); num2cell(hasLocalCpd(:))];
    end
end

[familyBels, logZ] = dgmInferQuery(dgm, queries, varargin{:}); 

if calcNodeBels
    nodeBels(hasLocalCpd) = familyBels(nnodes+1:end); 
    familyBels = familyBels(1:nnodes); 
end
end
