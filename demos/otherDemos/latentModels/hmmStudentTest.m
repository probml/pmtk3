%% Simple test of hmmFitEm with Student observations
%
%%

% This file is from pmtk3.googlecode.com

setSeed(0); 
loadData('data45');
data = [train4'; train5'];
d = 13;
model = hmmFitEm(data, 2, 'student', 'verbose', true);

