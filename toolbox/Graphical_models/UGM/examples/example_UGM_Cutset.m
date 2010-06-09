clear all
close all

% C20 Stops: West Mall at Stadium Road, Marine Drive at Agronomy Road, Marine Drive
% at University Boulevard, Marine Drive at Nitobe Memorial, Marine Drive at West
% Mall Road, Marine Drive at Crescent Road, Westbrook Mall at Iona Drive, UBC
% Loop Bay 15, Wesbrook Mall at University Boulevard, Wesbrook Mall at Agronomy
% Road, Thunderbird Boulevard at East Mall, Thunderbird Boulevard at Main Maill,
% West Mall at Hawthorne Lane, West Mall at Stadium Road

nNodes = 13;
nStates = 25;
adj = zeros(nNodes);
for i = 1:nNodes-1
    adj(i,i+1) = 1;
end
adj(nNodes,1) = 1;
adj = adj+adj';
edgeStruct = UGM_makeEdgeStruct(adj,nStates);

if 0
clf;
labels = {'UBCLoop','UniversityBoulevard','AgronomyRoad',...
    'EastMall','MainMall','HawthorneLane','StadiumRoad',...
    'AgronomyRoad','UniversityBoulevard','NitobeMemorial',...
    'WestMall','CrescentRoad','IonaDrive'};
drawGraph(adj,'labels',labels);
end

busy = [10
    8
    0
    3
    5
    4
    0
    5
    0
    0
    0
    0
    0];
nodePot = zeros(nNodes,nStates);
for n = 1:nNodes
   for s = 1:nStates
      nodePot(n,s) = exp(-(1/10)*(busy(n)-(s-1))^2);
   end
end
    
edgePot = zeros(nStates);
for s1 = 1:nStates
    for s2 = 1:nStates
        edgePot(s1,s2) = exp(-(1/100)*(s1-s2)^2);
    end
end
edgePot = repmat(edgePot,[1 1 edgeStruct.nEdges]);

clamped = zeros(nNodes,1);
clamped(1) = 11;

optimalDecoding = UGM_Decode_Conditional(nodePot,edgePot,edgeStruct,clamped,@UGM_Decode_Chain);
optimalNumber = optimalDecoding-1

[nodeBel,edgeBel,logZ] = UGM_Infer_Conditional(nodePot,edgePot,edgeStruct,clamped,@UGM_Infer_Chain);
nodeBel

samples = UGM_Sample_Conditional(nodePot,edgePot,edgeStruct,clamped,@UGM_Sample_Tree);
figure(1);
imagesc(samples'-1);
xlabel('Bus Stop');
ylabel('Number of People');
title('Conditional Samples');
colorbar

fprintf('(paused)\n');
pause

cutset = 1;
optimalDecoding = UGM_Decode_Cutset(nodePot,edgePot,edgeStruct,cutset);
optimalNumber = optimalDecoding-1

[nodeBel,edgeBel,logZ] = UGM_Infer_Cutset(nodePot,edgePot,edgeStruct,cutset);
nodeBel

samples = UGM_Sample_Cutset(nodePot,edgePot,edgeStruct,cutset);
figure(2);
imagesc(samples'-1);
xlabel('Bus Stop');
ylabel('Number of People');
title('Samples from Joint');
colorbar

fprintf('(paused)\n');
pause

%% Extended Problem

nNodes = 131;
nStates = 4;
adj = zeros(nNodes);
% Route 1 (loop starting from node 1)
for i = 1:12
    adj(i,i+1) = 1;
end
adj(13,1) = 1;
% Route 2 (loop starting from node 1)
adj(1,14) = 1;
for i = 14:29
   adj(i+1,i) = 1; 
end
adj(30,1) = 1;
% Route 3 (loop starting from node 70)
for i = 31:69
    adj(i+1,i) = 1;
end
adj(70,31) = 1;
% Route 4 (loop starting from node 81)
for i = 71:80
    adj(i,i+1) = 1;
end
adj(81,71) = 1;
% Route 5 (loop through nodes 1 and 70)
adj(1,82) = 1;
for i = 82:90
    adj(i,i+1) = 1;
end
adj(91,70) = 1;
adj(70,92) = 1;
for i = 92:99
    adj(i,i+1) = 1;
end
adj(100,1) = 1;
% Route 6 (loop through nodes 1 and 81)
adj(1,101) = 1;
for i = 101:110
    adj(i,i+1) = 1;
end
adj(111,81) = 1;
adj(81,112) = 1;
for i = 112:120
   adj(i,i+1) = 1; 
end
adj(121,1) = 1;
% Route 7 (direct path from 70 to 81)
adj(70,122) = 1;
for i = 122:130
    adj(i,i+1) = 1;
end
adj(131,81) = 1;

adj = adj+adj';

if 0
clf;
for i = 1:nNodes
    labels{1,i} = 's';
end
labels{1} = 'Hub';
labels{70} = 'Hub';
labels{81} = 'Hub';
drawGraph(adj,'labels',labels);
end

edgeStruct = UGM_makeEdgeStruct(adj,nStates);

busy = floor(rand(nNodes,1)*nStates);
nodePot = zeros(nNodes,nStates);
for n = 1:nNodes
   for s = 1:nStates
      nodePot(n,s) = exp(-(1/10)*(busy(n)-(s-1))^2);
   end
end
edgePot = zeros(nStates);
for s1 = 1:nStates
    for s2 = 1:nStates
        edgePot(s1,s2) = exp(-(1/10)*(s1-s2)^2);
    end
end
edgePot = repmat(edgePot,[1 1 edgeStruct.nEdges]);

if 0
clamped = zeros(nNodes,1);
clamped([1 70 81]) = 1;
[condNodePot,condEdgePot,condEdgeStruct,edgeMap] = UGM_makeClampedPotentials(nodePot,edgePot, edgeStruct, clamped);
adj = zeros(nNodes);
for e = 1:condEdgeStruct.nEdges
   adj(condEdgeStruct.edgeEnds(e,1), condEdgeStruct.edgeEnds(e,2)) = 1;
end
adj = adj+adj';
drawGraph(adj);
end

fprintf('Computing Optimal Decoding...\n');
cutset = [1 70 81];
optimalDecoding = UGM_Decode_Cutset(nodePot,edgePot,edgeStruct,cutset);
optimalNumber2 = optimalDecoding-1

fprintf('Computing Marginals and Normalizing Constant...\n');
[nodeBel,edgeBel,logZ] = UGM_Infer_Cutset(nodePot,edgePot,edgeStruct,cutset);
nodeBel

fprintf('Generating Samples...\n');
samples = UGM_Sample_Cutset(nodePot,edgePot,edgeStruct,cutset);
figure(3);
imagesc(samples'-1);
xlabel('Bus Stop');
ylabel('Number of People');
title('Samples from Joint');
colorbar