function  [samples] = UGM_Sample_Tree(nodePot, edgePot, edgeStruct)
% Note: structure must be a tree
% (does not currently support forests like other Tree functions)

[nNodes,maxState] = size(nodePot);
nEdges = size(edgePot,3);
edgeEnds = edgeStruct.edgeEnds;
nStates = edgeStruct.nStates;
V = edgeStruct.V;
E = edgeStruct.E;
maxIter = edgeStruct.maxIter;

% Compute Messages
maximize = 0;
messages = UGM_TreeBP(nodePot,edgePot,edgeStruct,maximize);

% Compute nodeBel
for n = 1:nNodes
    nodeBel(n,1:nStates(n)) = nodePot(n,1:nStates(n));

    edges = E(V(n):V(n+1)-1);
    for e = edges(:)'
        if n == edgeEnds(e,2)
            nodeBel(n,1:nStates(n)) = nodeBel(n,1:nStates(n)).*messages(1:nStates(n),e)';
        else
            nodeBel(n,1:nStates(n)) = nodeBel(n,1:nStates(n)).*messages(1:nStates(n),e+nEdges)';
        end

    end
    nodeBel(n,1:nStates(n)) = nodeBel(n,1:nStates(n))./sum(nodeBel(n,1:nStates(n)));
end

% Compute edgeBel
messages(messages==0) = inf; % Do the right thing for divide by zero case
edgeBel = zeros(maxState,maxState,nEdges);
for e = 1:nEdges
    n1 = edgeEnds(e,1);
    n2 = edgeEnds(e,2);
    belN1 = nodeBel(n1,1:nStates(n1))'./messages(1:nStates(n1),e+nEdges);
    belN2 = nodeBel(n2,1:nStates(n2))'./messages(1:nStates(n2),e);
    b1=repmat(belN1,1,nStates(n2));
    b2=repmat(belN2',nStates(n1),1);
    eb = b1.*b2.*edgePot(1:nStates(n1),1:nStates(n2),e);
    edgeBel(1:nStates(n1),1:nStates(n2),e) = eb./sum(eb(:));
end

% Make an ordering of nodes (right now, this is really innefficient)
colored = zeros(nNodes,1);
order = zeros(0,1);
parent = zeros(0,1);
parentEdge = zeros(0,1);
for root = 1:nNodes
    if colored(root) == 0
        colored(root) = 1;
        order(end+1,1) = root;
        parent(end+1,1) = 0;
        parentEdge(end+1,1) = 0;

        done = 0;
        while ~done
            done = 1;

            for e = 1:nEdges
                if sum(colored(edgeEnds(e,:)))==1
                    if colored(edgeEnds(e,1)) == 1
                        par = edgeEnds(e,1);
                        chi = edgeEnds(e,2);
                    else
                        par = edgeEnds(e,2);
                        chi = edgeEnds(e,1);
                    end
                    colored(chi) = 1;
                    order(end+1,1) = chi;
                    parent(end+1,1) = par;
                    parentEdge(end+1,1) = e;
                    done = 0;
                end
            end
        end
    end
end

% Now sample along the ordering
%samples = zeros(nNodes,maxIter);
for s = 1:maxIter
    y = zeros(nNodes,1);
    for o = 1:length(order)
        n = order(o);
        
        if parent(o) == 0
            y(n) = sampleDiscrete(nodeBel(n,:));
        else
            e = parentEdge(o);
            marg = nodeBel(n,:);
            marg(marg==0) = inf;
            marg = 1;
            if n == edgeEnds(e,2)
                join = edgeBel(y(parent(o)),:,e);
            else
                join = edgeBel(:,y(parent(o)),e)';
            end
            cond = join./marg;
            y(n) = sampleDiscrete(cond/sum(cond));
        end
    end
    samples(:,s) = y;
end