%% Simple test of hmmFit with tied mix Gauss observations
%
%%
setSeed(0); 
loadData('data45');
data = [train4'; train5'];
d = 13;
nstates = 3;
nmix    = 4; % must specify nmix

model = hmmFit(data, nstates, 'mixGaussTied', 'verbose', true, ...
    'nRandomRestarts', 3, 'nmix', nmix);


