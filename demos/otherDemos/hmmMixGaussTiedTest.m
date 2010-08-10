%% Simple test of hmmFit with tied mix Gauss observations
%
%%
loadData('data45');
data = [train4'; train5'];
d = 13;
nstates = 4;
nmix    = 6; % must specify nmix



model = hmmFit(data, nstates, 'mixGaussTied', 'verbose', true, 'piPrior', [3 2 2 2], ...
    'nRandomRestarts', 3, 'nmix', nmix);


