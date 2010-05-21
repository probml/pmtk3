clear all
rand('state',0);
randn('state',0);

%% Cheating Students
nNodes = 4;
adj = zeros(nNodes);
adj(1,2) = 1;
adj(2,3) = 1;
adj(3,4) = 1;
adj = adj + adj';
nStates = 2;
edgeStruct = UGM_makeEdgeStruct(adj,nStates);
nodePot = [1 3
    9 1
    1 3
    9 1];
edgePot = zeros(nStates,nStates,edgeStruct.nEdges);
edgePot(:,:,1) = [2 1 ; 1 2];
edgePot(:,:,2) = [2 1 ; 1 2];
edgePot(:,:,3) = [2 1 ; 1 2];

clamped = zeros(nNodes,1);
clamped(1) = 2;
clamped(3) = 2;

[nodeBel,edgeBel,logZ] = UGM_Infer_Conditional(nodePot,edgePot,edgeStruct,clamped,@UGM_Infer_Exact);
nodeBel

clamped(1) = 1;
clamped(3) = 1;
[nodeBel,edgeBel,logZ] = UGM_Infer_Conditional(nodePot,edgePot,edgeStruct,clamped,@UGM_Infer_Exact);
nodeBel
fprintf('(paused)\n');
pause

%% CS Grad Game of Life
nNodes = 60;
nStates = 7;
adj = zeros(nNodes);
for i = 1:nNodes-1
   adj(i,i+1) = 1;
end
adj = adj+adj';
edgeStruct = UGM_makeEdgeStruct(adj,nStates);
initial = [.3 .6 .1 0 0 0 0];
nodePot = zeros(nNodes,nStates);
nodePot(1,:) = initial;
nodePot(2:end,:) = 1;
transitions = [.08 .9 .01 0 0 0 .01
    .03 .95 .01 0 0 0 .01
    .06 .06 .75 .05 .05 .02 .01
    0 0 0 .3 .6 .09 .01
    0 0 0 .02 .95 .02 .01
    0 0 0 .01 .01 .97 .01
    0 0 0 0 0 0 1];
edgePot = repmat(transitions,[1 1 edgeStruct.nEdges]);

clamped = zeros(nNodes,1);
clamped(10) = 6;

optimalDecoding = UGM_Decode_Conditional(nodePot,edgePot,edgeStruct,clamped,@UGM_Decode_Tree)
[nodeBel,edgeBel,logZ] = UGM_Infer_Conditional(nodePot,edgePot,edgeStruct,clamped,@UGM_Infer_Tree);
nodeBel
samples = UGM_Sample_Conditional(nodePot,edgePot,edgeStruct,clamped,@UGM_Sample_Tree);
figure(1);
imagesc(samples');
xlabel('Year after graduation');
ylabel('Graduate');
colorbar
fprintf('(paused)\n');
pause

% Water Turbidity
load('waterSystem.mat'); % Loads adj
nNodes = length(adj);
nStates = 4;
edgeStruct = UGM_makeEdgeStruct(adj,nStates);
source = 4;
nodePot = ones(nNodes,nStates);
nodePot(source,:) = [.9 .09 .009 .001];
transition = [  0.9890    0.0099    0.0010    0.0001
    0.1309    0.8618    0.0066    0.0007
    0.0420    0.0841    0.8682    0.0057
    0.0667    0.0333    0.1667    0.7333];
colored = zeros(nNodes,1);
colored(source) = 1;
done = 0;
edgePot = zeros(nStates,nStates,edgeStruct.nEdges);
while ~done
    done = 1;
    colored_old = colored;
    
    for e = 1:edgeStruct.nEdges
        if sum(colored_old(edgeStruct.edgeEnds(e,:))) == 1
            % Determine direction of edge and color nodes
            if colored(edgeStruct.edgeEnds(e,1)) == 1
                edgePot(:,:,e) = transition;
            else
                edgePot(:,:,e) = transition';
            end
            colored(edgeStruct.edgeEnds(e,:)) = 1;
            done = 0;
        end
    end
end

clamped = zeros(nNodes,1);
clamped(4) = 4;

optimalDecoding = UGM_Decode_Conditional(nodePot,edgePot,edgeStruct,clamped,@UGM_Decode_Tree)
[nodeBel,edgeBel,logZ] = UGM_Infer_Conditional(nodePot,edgePot,edgeStruct,clamped,@UGM_Infer_Tree);
nodeBel
samples = UGM_Sample_Conditional(nodePot,edgePot,edgeStruct,clamped,@UGM_Sample_Tree);
figure(2);
imagesc(samples');
xlabel('Node');
ylabel('Sample');
colorbar
fprintf('(paused)\n');
pause

% Extended Water Turbidity
load('waterSystem2.mat'); % Loads adj
nNodes = length(adj);
nStates = 4;
edgeStruct = UGM_makeEdgeStruct(adj,nStates);
source = [1 6 7 8 11 12 15 17 19 20];
nodePot = ones(nNodes,nStates);
nodePot(source,:) = repmat([.9 .09 .009 .001],length(source),1);
transition = [  0.9890    0.0099    0.0010    0.0001
    0.1309    0.8618    0.0066    0.0007
    0.0420    0.0841    0.8682    0.0057
    0.0667    0.0333    0.1667    0.7333];
colored = zeros(nNodes,1);
colored(source) = 1;
coloredEdges = zeros(edgeStruct.nEdges,1);
done = 0;
edgePot = zeros(nStates,nStates,edgeStruct.nEdges);
while ~done
    done = 1;
    colored_old = colored;
    
    for e = 1:edgeStruct.nEdges
        if sum(colored_old(edgeStruct.edgeEnds(e,:))) == 1
            % Determine direction of edge and color nodes
            if colored(edgeStruct.edgeEnds(e,1)) == 1
                edgePot(:,:,e) = transition;
            else
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
      edgePot(:,:,e) = (transition+transition')/2;
   end
end

[nodeBel,edgeBel,logZ] = UGM_Infer_Tree(nodePot,edgePot,edgeStruct);
nodeBel
edgeStruct.maxIter = 100;
samples = UGM_Sample_Tree(nodePot,edgePot,edgeStruct);
figure(3);
imagesc(samples')
colorbar
xlabel('Node');
ylabel('Sample');

clamped = zeros(nNodes,1);
clamped(300) = 4;

samples = UGM_Sample_Conditional(nodePot,edgePot,edgeStruct,clamped,@UGM_Sample_Tree);
figure(4);
imagesc(samples');
xlabel('Node');
ylabel('Sample');
colorbar
[nodeBel,edgeBel,logZ] = UGM_Infer_Conditional(nodePot,edgePot,edgeStruct,clamped,@UGM_Infer_Tree);
nodeBel(source,:)



