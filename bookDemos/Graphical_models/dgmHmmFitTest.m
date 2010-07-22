%% Fit an HMM and an equivalent DGM and make sure the results agree
setSeed(0); 
%% Sample data
nstates   = 2;
d         = 2; 
T         = 20; 
nsamples  = 3; 
hmmSource = mkRndGaussHmm(nstates, d); 
[Y, Z] = hmmSample(hmmSource, T, nsamples); 
%% Create an hmm-like random dgm
dgmModel = hmm2Dgm(mkRndGaussHmm(nstates, d), T);  
%% First the fully observed case

hmmModel = hmmFitFullyObs(Z, Y, 'gauss'); 

localev  = hmmObs2LocalEv(Y); 
data     = cell2mat(Z); 
%dgmModel.CPDs{1}.prior = hmmModel.piPrior(:); 
%dgmModel.CPDs{2}.prior = hmmModel.transPrior ;
dgmModel.localCPD.prior = hmmModel.emissionPrior; 
dgmModel = dgmFitFullyObs(dgmModel, data, 'localev', localev); 


pi    = hmmModel.pi;
A     = hmmModel.A; 
Ehmm  = hmmModel.emission;
Edgm  = dgmModel.localCPDs; % only one since tied
piDgm = dgmModel.CPDs{1}.T'; 
Adgm  = dgmModel.CPDs{2}.T;
assert(approxeq(pi, piDgm)); 
assert(approxeq(A, Adgm)); 

assert(approxeq(Ehmm.mu, Edgm.mu)); 
assert(approxeq(Ehmm.Sigma, Edgm.Sigma)); 