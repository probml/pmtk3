%% Fit an HMM and an equivalent DGM and make sure the results agree
%
%%

% This file is from pmtk3.googlecode.com

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
dgmModel  = hmmToDgm(mkRndGaussHmm(nstates, d), T);  
% fit the hmm model
hmmModel = hmmFitFullyObs(Z, Y, 'gauss'); 
% convert data to dgm format
localev  = hmmObs2LocalEv(Y); 
data     = cell2mat(Z); 
% make sure they have the same priors
% KPM 25Oct10 added -1 to priors
% because tabularCpd now interprets prior as pseudocounts (alpha-1) 
dgmModel.CPDs{1}.prior = hmmModel.piPrior(:)-1; 
dgmModel.CPDs{2}.prior = hmmModel.transPrior-1;
dgmModel.localCPDs{1}.prior = hmmModel.emission.prior; % no -1 
% fit dgm
dgmModel = dgmTrain(dgmModel,'data', data, 'localev', localev); 
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








