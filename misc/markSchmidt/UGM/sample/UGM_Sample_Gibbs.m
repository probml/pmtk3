function [samples] = UGM_Sample_Gibbs(nodePot,edgePot,edgeStruct,burnIn,y)
% [samples] = UGM_Sample_Gibbs(nodePot,edgePot,edgeStruct,burnIn,y)
% Single Site Gibbs Sampling

if nargin < 5
% Initialize
[junk y] = max(nodePot,[],2);
end

if edgeStruct.useMex
    samples = UGM_Sample_GibbsC(nodePot,edgePot,int32(edgeStruct.edgeEnds),int32(edgeStruct.nStates),int32(edgeStruct.V),int32(edgeStruct.E),edgeStruct.maxIter,burnIn,int32(y));
else
    samples = Sample_Gibbs(nodePot,edgePot,edgeStruct,burnIn,y);
end

end

function [samples] = Sample_Gibbs(nodePot,edgePot,edgeStruct,burnIn,y)
[nNodes,maxStates] = size(nodePot);
nEdges = size(edgePot,3);
edgeEnds = edgeStruct.edgeEnds;
V = edgeStruct.V;
E = edgeStruct.E;
nStates = edgeStruct.nStates;
maxIter = edgeStruct.maxIter;

samples = zeros(nNodes,0);

for i = 1:burnIn+maxIter
    for n = 1:nNodes

        % Compute Node Potential
        pot = nodePot(n,1:nStates(n));

        % Find Neighbors
        edges = E(V(n):V(n+1)-1);

        % Multiply Edge Potentials
        for e = edges(:)'
            n1 = edgeEnds(e,1);
            n2 = edgeEnds(e,2);

            if n == edgeEnds(e,1)
                ep = edgePot(1:nStates(n1),y(n2),e)';
            else
                ep = edgePot(y(n1),1:nStates(n2),e);
            end
            pot = pot .* ep;
        end

        % Sample State;
        y(n) = sampleDiscrete(pot./sum(pot));
    end
    
    if i > burnIn
        samples(:,i-burnIn) = y;
    end
end
end