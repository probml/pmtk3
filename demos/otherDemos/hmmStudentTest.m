%% Simple test of hmmFitEm with Student observations
%
%%
%setSeed(0); 
loadData('data45');
data = [train4'; train5'];
d = 13;
model = hmmFitEm(data, 3, 'student', 'verbose', true,  'nRandomRestarts', 3);

