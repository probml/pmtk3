clear all

rand('state',0);
randn('state',0);

% Generate Adjacency Matrix
nNodes = 100;
nStates = 4;
nSources = 1;

edgeStruct = UGM_makeEdgeStruct(setdiag(ones(nNodes),0),nStates);
tree = minSpan(nNodes,[edgeStruct.edgeEnds rand(edgeStruct.nEdges,1)]);

adj = zeros(nNodes);
for e = 1:edgeStruct.nEdges
    if tree(e) == 1
        adj(edgeStruct.edgeEnds(e,1),edgeStruct.edgeEnds(e,2)) = 1;
    end
end
adj = adj+adj';

s = 1;
for n = 1:nNodes
    if sum(adj(n,:))==1
        if s <= nSources
            labels{1,n} = 'Source';
            sources(s) = n;
            s = s+1;
        else
            labels{1,n} = 'Tap';
        end
    else
        labels{1,n} = 'I';
    end
end
sources

if 0
clf;
drawGraph(adj,'labels',labels);
%drawGraph(adj);
pause
end

edgeStruct = UGM_makeEdgeStruct(adj,nStates);

nodePot = ones(nNodes,nStates);
for n = 1:nNodes
    if strcmp(labels{1,n},'Source') == 1
        nodePot(n,:) = [.9 .09 .009 .001];
    else
        nodePot(n,:) = [1 1 1 1];
    end
end

transition = [  0.9890    0.0099    0.0010    0.0001
    0.1309    0.8618    0.0066    0.0007
    0.0420    0.0841    0.8682    0.0057
    0.0667    0.0333    0.1667    0.7333];

colored = zeros(nNodes,1);
colored(sources) = 1;
coloredEdges = zeros(edgeStruct.nEdges,1);
done = 0;
edgePot = zeros(nStates,nStates,edgeStruct.nEdges);
while ~done
    done = 1;
    colored_old = colored;
    
    for e = 1:edgeStruct.nEdges
        if sum(colored_old(edgeStruct.edgeEnds(e,:))) == 1
            %fprintf('Coloring %d--%d (edge %d)\n',edgeStruct.edgeEnds(e,:),e);
            % Determine direction of edge and color nodes
            if colored(edgeStruct.edgeEnds(e,1)) == 1
                %fprintf('Forward Edge\n');
                edgePot(:,:,e) = transition;
            else
                %fprintf('Backward Edge\n');
                edgePot(:,:,e) = transition';
            end
            colored(edgeStruct.edgeEnds(e,:)) = 1;
            coloredEdges(e) = 1;
            done = 0;
        end
    end
end
for e = 1:edgeStruct.nEdges
   if coloredEdges(e) == 0
      edgePot(:,:,e) = (transition+transition')/2 
   end
end

optimalDecoding = UGM_Decode_Tree(nodePot,edgePot,edgeStruct)

[nodeBel,edgeBel,logZ] = UGM_Infer_Tree(nodePot,edgePot,edgeStruct)

edgeStruct.maxIter = 100;
samples = UGM_Sample_Tree(nodePot,edgePot,edgeStruct);
imagesc(samples')
colorbar
xlabel('Node');
ylabel('Sample');