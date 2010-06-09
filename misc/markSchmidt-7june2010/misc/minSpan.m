function [E] = minSpan(nNodes,edgeEnds)
% [E] = minSpan(nNodes,edgeEnds)
%
% Compute minimum spanning tree using Prim's algorithm
%
% edgeEnds(e,[n1 n2 w]):
%   gives the two nodes and weight for each e

nEdges = size(edgeEnds,1);

% Initialize with no nodes or edges included
V = zeros(nNodes,1);
E = zeros(nEdges,1);

% Sort edges by weight
[sorted,sortedInd] = sort(edgeEnds(:,3));

% Randomly add an initial node
V(ceil(rand*nNodes)) = 1;

done = 0;
while ~done
    done = 1;

    % Find minimal weight edge s.t. V(n1) = 0 and V(n2) = 1 or vice versa
    for e = 1:nEdges
        n1 = edgeEnds(sortedInd(e),1);
        n2 = edgeEnds(sortedInd(e),2);
        if V(n1) == 0 && V(n2) == 1
            V(n1) = 1;
            E(sortedInd(e)) = 1;
            done = 0;
            break;
        elseif V(n2) == 0 && V(n1) == 1
            V(n2) = 1;
            E(sortedInd(e)) = 1;
            done = 0;
            break;
        end
    end


end

    if 0
        % Draw Graph
        adj = zeros(nNodes);
        for e = 1:nEdges
            if E(e) == 1
                adj(edgeEnds(e,1),edgeEnds(e,2)) = 1;
            end
        end
        adj = adj+adj';
        draw_layout(adj);
        pause;
    end