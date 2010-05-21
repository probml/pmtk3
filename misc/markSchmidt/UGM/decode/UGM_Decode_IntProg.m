function  [y] = UGM_Infer_LP(nodePot, edgePot, edgeStruct)
% INPUT
% nodePot(node,class)
% edgePot(class,class,edge) where e is referenced by V,E (must be the same
% between feature engine and inference engine)
%
% OUTPUT
% nodeLabel(node)

[nNodes,maxState] = size(nodePot);
nEdges = size(edgePot,3);
edgeEnds = edgeStruct.edgeEnds;
V = edgeStruct.V;
E = edgeStruct.E;
nStates = edgeStruct.nStates;

if nEdges == 0;
   [junk y] = max(nodePot,[],2);
   return
end

% Find Active Variables
% (relevant if nodes have different number of states)
if min(nStates) ~= max(nStates)
    active = zeros(nNodes,maxState);
    activeEdge = zeros(maxState,maxState,nEdges);
    for n = 1:nNodes
        active(n,1:nStates(n)) = 1;
    end
    for e = 1:nEdges
        activeEdge(1:nStates(edgeEnds(e,1)),1:nStates(edgeEnds(e,2)),e) = 1;
    end
    nNodeVars = sum(active(:));
    nEdgeVars = sum(activeEdge(:));
else
    active = ones(nNodes,maxState);
    activeEdge = ones(maxState,maxState,nEdges);
    nNodeVars = nNodes*maxState;
    nEdgeVars = maxState*maxState*nEdges;
end

% Enforce that Node Variables must sum to 1
B1 = ones(nNodes,1);
A1_node = zeros(nNodes,nNodes*maxState);
for n = 1:nNodes
    for s = 1:maxState
        A1_node(n,sub2ind([nNodes maxState],n,s)) = 1;
    end
end

% Enforce that summing over Edge Variables gives Node Variables
c = 1;
nMargConst = sum(nStates(edgeEnds(:)));
A2_node = zeros(nMargConst,nNodes*maxState);
A2_edge = zeros(nMargConst,maxState*maxState*nEdges);
for e = 1:nEdges
    n1 = edgeEnds(e,1);
    n2 = edgeEnds(e,2);

    for s1 = 1:nStates(n1)
        A2_node(c,sub2ind([nNodes maxState],n1,s1)) = -1;
        for s2 = 1:nStates(n2)
            A2_edge(c,sub2ind([maxState maxState nEdges],s1,s2,e)) = 1;
        end
        c = c + 1;
    end

    for s2 = 1:nStates(n2)
        A2_node(c,sub2ind([nNodes maxState],n2,s2)) = -1;
        for s1 = 1:nStates(n1)
            A2_edge(c,sub2ind([maxState maxState nEdges],s1,s2,e)) = 1;
        end
        c = c + 1;
    end
end
B2 = zeros(c-1,1);

% Remove Inactive Variables
A1_node = A1_node(:,active(:)==1);
A2_node = A2_node(:,active(:)==1);
A2_edge = A2_edge(:,activeEdge(:)==1);

% Combine Equality Constraints
Aeq = [A1_node zeros(nNodes,nEdgeVars)
    A2_node A2_edge];
Beq = [B1;B2];

% Make objective
f_node = nodePot(active(:)==1);
f_edge = edgePot(activeEdge(:)==1);
f = -log([f_node;f_edge]);

% Solve integer program
if exist('glpkcc') == 3
    x = glpk(f,Aeq,Beq,[],[],repmat('S',size(Beq)),repmat('B',size(f)));
else
    x = bintprog(f,[],[],Aeq,Beq);
end

% Form final solution
nodeBel = zeros(nNodes,maxState);
nodeBel(active==1) = x(1:nNodeVars);
[junk y] = max(nodeBel,[],2);