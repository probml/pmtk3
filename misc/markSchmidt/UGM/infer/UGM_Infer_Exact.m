function  [nodeBel, edgeBel, logZ] = UGM_Infer_Exact(nodePot, edgePot, edgeStruct)
% INPUT
% nodePot(node,class)
% edgePot(class,class,edge) where e is referenced by V,E (must be the same
% between feature engine and inference engine)
%
% OUTPUT
% nodeBel(node,class) - marginal beliefs
% edgeBel(class,class,e) - pairwise beliefs
% logZ - negative of free energy

assert(prod(edgeStruct.nStates) < 50000000,'Brute Force Exact Inference not recommended for models with > 50 000 000 states');

if edgeStruct.useMex
   [nodeBel,edgeBel,logZ] = UGM_Infer_ExactC(nodePot,edgePot,int32(edgeStruct.edgeEnds),int32(edgeStruct.nStates));
else
   [nodeBel,edgeBel,logZ] = Infer_Exact(nodePot,edgePot,edgeStruct);
end
end

function  [nodeBel, edgeBel, logZ] = Infer_Exact(nodePot, edgePot, edgeStruct)

[nNodes,maxStates] = size(nodePot);
nEdges = size(edgePot,3);
edgeEnds = edgeStruct.edgeEnds;
nStates = edgeStruct.nStates;


% Initialize
nodeBel = zeros(size(nodePot));
edgeBel = zeros(size(edgePot));
y = ones(1,nNodes);
Z = 0;
i = 1;
while 1
    
    pot = UGM_ConfigurationPotential(y,nodePot,edgePot,edgeEnds);
    
    % Update nodeBel
    for n = 1:nNodes
        nodeBel(n,y(n)) = nodeBel(n,y(n))+pot;
    end
    
    % Update edgeBel
    for e = 1:nEdges
        n1 = edgeEnds(e,1);
        n2 = edgeEnds(e,2);
        edgeBel(y(n1),y(n2),e) = edgeBel(y(n1),y(n2),e)+pot;
    end
    
    % Update Z
    Z = Z + pot;
    
    % Go to next y
    for yInd = 1:nNodes
        y(yInd) = y(yInd) + 1;
        if y(yInd) <= nStates(yInd)
            break;
        else
            y(yInd) = 1;
        end
    end
    
    % Stop when we are done all y combinations
    
      if  yInd == nNodes && y(end) == 1
        break;
    end
end

nodeBel = nodeBel./Z;
edgeBel = edgeBel./Z;
logZ = log(Z);


end