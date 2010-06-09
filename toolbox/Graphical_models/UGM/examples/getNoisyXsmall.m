
clear all
close all
load X.mat

X = X(1:16,1:16);

figure(1);
imagesc(X);
colormap gray
title('Original X Arm');

figure(2);
X = X + randn(size(X))/2;
imagesc(X);
colormap gray
title('Noisy X Arm');

%% Represent denoising as UGM

[nRows,nCols] = size(X);
nNodes = nRows*nCols;
nStates = 2;

adj = sparse(nNodes,nNodes);

% Add Down Edges
ind = 1:nNodes;
exclude = sub2ind([nRows nCols],repmat(nRows,[1 nCols]),1:nCols); % No Down edge for last row
ind = setdiff(ind,exclude);
adj(sub2ind([nNodes nNodes],ind,ind+1)) = 1;

% Add Right Edges
ind = 1:nNodes;
exclude = sub2ind([nRows nCols],1:nRows,repmat(nCols,[1 nRows])); % No right edge for last column
ind = setdiff(ind,exclude);
adj(sub2ind([nNodes nNodes],ind,ind+nCols)) = 1;

% Add Up/Left Edges
adj = adj+adj';
edgeStruct = UGM_makeEdgeStruct(adj,nStates);

if 0 % Hand-picked parameters
    % Make nodePot
    nodePot = zeros(nNodes,nStates);
    nodePot(:,1) = 1./(1+exp(X(:)-.5));
    nodePot(:,2) = 1-nodePot(:,1);

    % Make edgePot
    edgePot = zeros(nStates,nStates,edgeStruct.nEdges);
    edgePot = repmat([1.35 1;1 1.35],[1 1 edgeStruct.nEdges]);
else % Learned optimal sub-modular parameters
    Xstd = UGM_standardizeCols(reshape(X,[1 1 nNodes]),1);
    nodePot = zeros(nNodes,nStates);
    nodePot(:,1) = exp(-1-2.5*Xstd(:));
    nodePot(:,2) = 1;

    edgePot = zeros(nStates,nStates,edgeStruct.nEdges);
    for e = 1:edgeStruct.nEdges
        n1 = edgeStruct.edgeEnds(e,1);
        n2 = edgeStruct.edgeEnds(e,2);

        pot_same = exp(1.8 + .3*1/(1+abs(Xstd(n1)-Xstd(n2))));
        edgePot(:,:,e) = [pot_same 1;1 pot_same];
    end
end
