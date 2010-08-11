%% Simple test of hmmFit with tied mix Gauss observations
%
%%

loadData('data45');
data = [train4'; train5'];
d = 13;
nstates = 2;
nmix    = 3; % must specify nmix

model = hmmFit(data, nstates, 'mixGaussTied', 'verbose', true, ...
    'nRandomRestarts', 3, 'nmix', nmix); 


localev = hmmObs2LocalEv(data); 
dgm = hmmToDgm(model, 131); 

dgm2 = dgmFit(dgm, 'localev', localev, 'verbose', true);