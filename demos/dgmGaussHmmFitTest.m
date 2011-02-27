%% Fit an HMM and an equivalent DGM, making sure the results agree
%
%% sample data

%
%                Note, unlike hmmFit, dgmTrain does not use cell arrays,
%                instead it takes an NaN-padded matrix of size
%                nobs-by-d-max(seqLength). You can use the localEv2HmmObs
%                and hmmObs2LocalEv functions to convert between these
%                two formats.
%

% This file is from pmtk3.googlecode.com

setSeed(0); 
nstates   = 10;
d         = 13; 
T         = 12; 
nsamples  = 15; 
hmmSource = mkRndGaussHmm(nstates, d); 
[Y, Z]    = hmmSample(hmmSource, T, nsamples); 
Y         = cellwrap(Y);
Z         = cellwrap(Z);
%% create an hmm-like random dgm
dgmModel  = hmmToDgm(mkRndGaussHmm(nstates, d), T);  
%% convert data to dgm format
localev  = hmmObs2LocalEv(Y); 
%data     = cell2mat(Z); 
%% make sure we initialize both models in the same way
pi0    = normalize(rand(1, nstates)); 
trans0 = normalize(rand(nstates, nstates), 2); 
Sigma0 = zeros(d, d, nstates); 
for i=1:nstates
    Sigma0(:, :, i) = randpd(d) + 2*eye(d); 
end
mu0 = randn(d, nstates); 
emission0 = condGaussCpdCreate(mu0, Sigma0); 
%% fit the hmm
fprintf('\nHMM\n'); 
tic
hmmModel = hmmFitEm(Y, nstates, 'gauss', ...
    'pi0'       , pi0       , ...
    'trans0'    , trans0    , ...
    'emission0' , emission0 , ...
    'verbose'   , true      );
toc
%% initialize the dgm 
dgmModel.localCPDs          = {emission0};
dgmModel.localCPDs{1}.prior = hmmModel.emission.prior; 
dgmModel.CPDs{1}            = tabularCpdCreate(pi0(:), 'prior', hmmModel.piPrior(:)); 
dgmModel.CPDs{2}            = tabularCpdCreate(trans0, 'prior', hmmModel.transPrior); 
%% fit the dgm
fprintf('\nDGM\n'); 
tic; dgmModel = dgmTrain(dgmModel, 'localev', localev, 'verbose', true);toc
%% compare results
hmmPi = hmmModel.pi(:); 
dgmPi = dgmModel.CPDs{1}.T(:);
assert(approxeq(hmmPi, dgmPi)); 

hmmA = hmmModel.A;
dgmA = dgmModel.CPDs{2}.T;
assert(approxeq(hmmA, dgmA)); 

hmmMu = hmmModel.emission.mu;
dgmMu = dgmModel.localCPDs{1}.mu;
assert(approxeq(hmmMu, dgmMu)); 

hmmSigma = hmmModel.emission.Sigma;
dgmSigma = dgmModel.localCPDs{1}.Sigma;
assert(approxeq(hmmSigma, dgmSigma)); 
