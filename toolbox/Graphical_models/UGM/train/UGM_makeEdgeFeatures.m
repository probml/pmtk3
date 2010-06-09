function [Xedge] = UGM_makeEdgeFeatures(X,edgeEnds,globalFeatures)
% function [Xedge] = UGM_makeEdgeFeatures(X,edgeEnds,globalFeatures)
%
% X(instance,feature,node)
% edgeEnds(edge,[node1 node2])
% globalFeatures(feature): (optional) vector that is set to 1 if the
% feature is shared across nodes

[nInstances,nFeatures,nNodes] = size(X);
nEdges = size(edgeEnds,1);

if nargin < 3
    globalFeatures = zeros(nFeatures,1);
end

existGF = sum(globalFeatures) > 0;
existLF = any(globalFeatures==0);
if existGF && ~existLF
    nEdgeFeatures = nFeatures;
elseif existGF
    nEdgeFeatures = nFeatures*2-sum(globalFeatures);
else
    nEdgeFeatures = nFeatures*2;
end

% Compute Edge Features (use node features from both nodes)
Xedge = zeros(nInstances,nEdgeFeatures,nEdges);
for i = 1:nInstances
    for e = 1:nEdges
        n1 = edgeEnds(e,1);
        n2 = edgeEnds(e,2);
        if existGF && ~existLF
            % Only global features
            Xedge(i,:,e) = X(i,:,n1);
        elseif existGF
            % Global and local features
            Xedge(i,:,e) = [X(i,:,n1) X(i,find(globalFeatures==0),n2)];
        else
            % Only local features
            Xedge(i,:,e) = [X(i,:,n1) X(i,:,n2)];
        end
    end
end