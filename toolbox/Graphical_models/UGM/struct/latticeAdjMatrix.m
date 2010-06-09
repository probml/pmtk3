function [adjMatrix] = fixed_Lattice(nRows,nCols)
nNodes = nRows*nCols;

adjMatrix = sparse(nNodes,nNodes);

% Add Down Edges
ind = 1:nNodes;
exclude = sub2ind([nRows nCols],repmat(nRows,[1 nCols]),1:nCols); % No Down edge for last row
ind = setdiff(ind,exclude);
adjMatrix(sub2ind([nNodes nNodes],ind,ind+1)) = 1;

% Add Right Edges
ind = 1:nNodes;
exclude = sub2ind([nRows nCols],1:nRows,repmat(nCols,[1 nRows])); % No right edge for last column
ind = setdiff(ind,exclude);
adjMatrix(sub2ind([nNodes nNodes],ind,ind+nCols)) = 1;

% Add Up/Left Edges
adjMatrix = adjMatrix+adjMatrix';