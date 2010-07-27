%% Fit an HMM and an equivalent DGM and make sure the results agree
setSeed(2); 
%% sample data
nstates   = 10;
d         = 13; 
T         = 11; 
nsamples  = 15; 
hmmSource = mkRndGaussHmm(nstates, d); 
[Y, Z]    = hmmSample(hmmSource, T, nsamples); 
Y         = cellwrap(Y);
Z         = cellwrap(Z);
%% create an hmm-like random dgm
dgmModel  = hmm2Dgm(mkRndGaussHmm(nstates, d), T);  
% fit the hmm model
hmmModel = hmmFitFullyObs(Z, Y, 'gauss'); 
% convert data to dgm format
localev  = hmmObs2LocalEv(Y); 
data     = cell2mat(Z); 
% make sure they have the same priors
dgmModel.CPDs{1}.prior = hmmModel.piPrior(:); 
dgmModel.CPDs{2}.prior = hmmModel.transPrior ;
dgmModel.localCPDs{1}.prior = hmmModel.emissionPrior; 
% fit dgm
dgmModel = dgmFit(dgmModel,'data', data, 'localev', localev); 
%% compare results
pi    = hmmModel.pi;
A     = hmmModel.A; 
Ehmm  = hmmModel.emission;
Edgm  = dgmModel.localCPDs{1}; 
piDgm = dgmModel.CPDs{1}.T'; 
Adgm  = dgmModel.CPDs{2}.T;
assert(approxeq(pi, piDgm)); 
assert(approxeq(A, Adgm)); 
assert(approxeq(Ehmm.mu, Edgm.mu)); 
assert(approxeq(Ehmm.Sigma, Edgm.Sigma)); 
%%








