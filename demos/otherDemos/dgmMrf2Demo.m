%% Convert a dgm to a pairwise mrf
dgm = mkSprinklerDgm;
%% first compute marginals using dgmInferNodes
nodeBels = dgmInferNodes(dgm); 
%% compare these to beliefs from equivalent pairwise fg
fg2 = factorGraphMakePairwise(dgmToFactorGraph(dgm));
cg2 = cliqueGraphCreate(fg2.factors, fg2.nstates);
jt2 = jtreeCalibrate(jtreeCreate(cg2));
nodeBels2 = jtreeQuery(jt2, num2cell(1:4));
tfequal(nodeBels, nodeBels2); 
%% convert to Mark Schmidt's UGM format

fg = dgmToFactorGraph(dgm);
mrf2 = factorGraphToMrf2(fg, 'method', 'Exact'); 
mrf2.edgeStruct.useMex = false;
nodeBels3 = mrf2InferMarginals(mrf2);
% remove padding:
nodeBels3 = nodeBels3(1:4, 1:2)';
assert(approxeq(nodeBels3, tfMarg2Mat(nodeBels))); 
