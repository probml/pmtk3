function [logZ, bels] = jtreeRunInference(jtree, queries, localFactors)
%% Run inference on the a jtree
% Called by e.g. mrfInferQuery, and dgmInferQuery
%%

% This file is from pmtk3.googlecode.com

[jtree, logZlocal]= jtreeAddFactors(jtree, localFactors);
[jtree, logZ]     = jtreeCalibrate(jtree);
bels              = jtreeQuery(jtree, queries);
logZ              = logZ + logZlocal;
end
