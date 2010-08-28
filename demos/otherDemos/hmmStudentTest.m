%% Simple test of hmmFitEm with Student observations
%
%%
loadData('data45');
data = [train4'; train5'];
d = 13;
model = hmmFitEm(data, 2, 'student', 'verbose', true, 'piPrior', [3 2], 'nRandomRestarts', 3);

