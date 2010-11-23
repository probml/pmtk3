%% Convert a dgm to a pairwise mrf
%
%%

% This file is from pmtk3.googlecode.com

dgm = mkSprinklerDgm;
%% first compute marginals using dgmInferNodes
nodeBels = dgmInferNodes(dgm); 
%% compare these to beliefs from equivalent pairwise fg (low level)
fg2 = factorGraphMakePairwise(dgmToFactorGraph(dgm));
cg2 = cliqueGraphCreate(fg2.factors, fg2.nstates);
jt2 = jtreeCalibrate(jtreeCreate(cg2));
nodeBels2 = jtreeQuery(jt2, num2cell(1:4));
tfequal(nodeBels, nodeBels2); 

%% convert to Mark Schmidt's UGM format
mrf2 = dgmToMrf2(dgm, 'method', 'Tree'); 
nodeBels3 = mrf2InferNodesAndEdges(mrf2);
% remove padding:
nodeBels3 = nodeBels3(1:4, 1:2)';
assert(approxeq(nodeBels3, tfMarg2Mat(nodeBels))); 
%% quick mrfToMrf2 test
mrf = dgmToMrf(dgm);
nodeBels4 = mrfInferNodes(mrf);
tfequal(nodeBels4, nodeBels); 
mrf2 = mrfToMrf2(mrf, 'method', 'Tree'); 
nodeBels5 = mrf2InferNodesAndEdges(mrf2); 
nodeBels5 = nodeBels5(1:4, 1:2)';
assert(approxeq(nodeBels5, tfMarg2Mat(nodeBels))); 
