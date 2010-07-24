%% Test dgmFit on the alarm network 
%
%%
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
dgmAll = dgmFit(dgm, 'data', S); 
%% hide some of the data
SS = S;
SS(1:3:end) = 0; 
%% fit the dgm given missing data
dgmMiss = dgmFit(dgm, 'data', SS, 'verbose', true, 'maxIter', 5); 
