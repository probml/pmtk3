%% Simple test of hmmFit with tied mix Gauss observations
%
%%

% This file is from pmtk3.googlecode.com


loadData('speechDataDigits4And5');
data = [train4'; train5'];
d = 13;
nstates = 2;
nmix    = 3; % must specify nmix

model = hmmFit(data, nstates, 'mixGaussTied', 'verbose', true, ...
    'nRandomRestarts', 2, 'maxiter', 5, 'nmix', nmix); 

if 0
    
    localev = hmmObs2LocalEv(data);
    localev(1:3:end) = nan; % use dgmTrain for arbitrarily missing local ev
    Tmax = 131; % maximum length of the sequences.
    dgm = hmmToDgm(model, Tmax);
    
    dgm2 = dgmTrain(dgm, 'localev', localev, 'verbose', true);
    
end

% This doesn't actually test anything!

