function fg = mrfToFactorGraph(mrf)
%% Convert an mrf to a factorGraph

% This file is from pmtk3.googlecode.com

fg = factorGraphCreate(mrf.cliqueGraph.Tfac, mrf.nstates); 
end
