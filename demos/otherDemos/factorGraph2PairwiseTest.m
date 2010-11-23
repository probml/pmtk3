%% Test that factorGraphMakePairwise creates an equivalent model
% by comparing the results of inference
%%

% This file is from pmtk3.googlecode.com


setSeed(0); 
nnodes     = 10;
maxFanIn   = 2;
maxFanOut  = 3;
maxNstates = 3; 
ntrials    = 10; 

for i=1:ntrials
    dgm       = mkRndDgm(nnodes, maxFanIn, maxFanOut, maxNstates);
    nnodes    = dgm.nnodes;
    fg        = dgmToFactorGraph(dgm);
    fg2       = factorGraphMakePairwise(fg);
    cg        = cliqueGraphCreate(fg.factors, fg.nstates);
    cg2       = cliqueGraphCreate(fg2.factors, fg2.nstates);
    jt        = jtreeCalibrate(jtreeCreate(cg));
    jt2       = jtreeCalibrate(jtreeCreate(cg2));
    nodeBels1 = jtreeQuery(jt, num2cell(1:nnodes));
    nodeBels2 = jtreeQuery(jt2, num2cell(1:nnodes));
    
    assert(fg2.isPairwise);
    assert(~fg.isPairwise);
    assert(tfequal(nodeBels1, nodeBels2));
end

%%
