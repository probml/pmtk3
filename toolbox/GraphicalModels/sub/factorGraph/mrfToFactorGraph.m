function fg = mrfToFactorGraph(mrf)
%% Convert an mrf to a factorGraph
fg = factorGraphCreate(mrf.cliqueGraph.Tfac, mrf.nstates); 
end