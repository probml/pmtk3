%% Test dgmTrain on the alarm network 
%
%%

% This file is from pmtk3.googlecode.com

setSeed(0); 
dgmSource = mkAlarmDgm();
G = dgmSource.G; 
nstates = dgmSource.nstates;
%% sample
nsamples = 20; 
S = dgmSample(dgmSource, nsamples); 
%% create a random initial dgm
dgm = dgmCreate(G, mkRndTabularCpds(G, nstates)); 
%% fit using all of the data
dgmAll = dgmTrain(dgm, 'data', S); 
%% hide some of the data
SS = S;
SS(1:3:end) = 0; 
%% fit the dgm given missing data
dgmMiss = dgmTrain(dgm, 'data', SS, 'verbose', true, 'maxIter', 5); 
