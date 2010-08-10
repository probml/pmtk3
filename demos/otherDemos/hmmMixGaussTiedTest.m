%% Simple test of hmmFit with tied mix Gauss observations
%
%%

loadData('data45');
data = [train4'; train5'];
d = 13;
nstates = 3;
nmix    = 5; % must specify nmix

  


model = hmmFit(data, nstates, 'mixGaussTied', 'verbose', true, ...
    'nRandomRestarts', 10, 'nmix', nmix); 

