%% Simple test of hmmFit with tied mix Gauss observations
%
%%
loadData('data45');
data = [train4'; train5'];
d = 13;
nstates = 3;
nmix    = 2; % must specify nmix



model = hmmFit(data, nstates, 'mixGaussTied', 'verbose', true, ...
    'nRandomRestarts', 3, 'nmix', nmix);


