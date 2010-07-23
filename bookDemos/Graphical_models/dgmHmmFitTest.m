%% Fit an HMM and an equivalent DGM and make sure the results agree
setSeed(2); 
%% sample data
nstates   = 10;
d         = 13; 
T         = 11; 
nsamples  = 15; 
hmmSource = mkRndGaussHmm(nstates, d); 
[Y, Z] = hmmSample(hmmSource, T, nsamples); 
Y = cellwrap(Y);
Z = cellwrap(Z);
%% create an hmm-like random dgm
dgmModel = hmm2Dgm(mkRndGaussHmm(nstates, d), T);  
%% first the fully observed case
%
%% fit the hmm model
hmmModel = hmmFitFullyObs(Z, Y, 'gauss'); 
%% convert data to dgm format
localev  = hmmObs2LocalEv(Y); 
data     = cell2mat(Z); 
%% make sure they have the same priors
dgmModel.CPDs{1}.prior = hmmModel.piPrior(:); 
dgmModel.CPDs{2}.prior = hmmModel.transPrior ;
dgmModel.localCPDs{1}.prior = hmmModel.emissionPrior; 
%% fit dgm
dgmModel = dgmFitFullyObs(dgmModel, data, 'localev', localev); 
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
%% now try the unobserved case
pi0    = normalize(rand(1, nstates)); 
trans0 = normalize(rand(nstates, nstates), 2); 
Sigma0 = zeros(d, d, nstates); 
for i=1:nstates
    Sigma0(:, :, i) = randpd(d) + 2*eye(d); 
end
mu0 = randn(d, nstates); 
emission0 = condGaussCpdCreate(mu0, Sigma0); 
maxIter = 5;

fprintf('\nHMM\n'); 
hmmModel = hmmFitEm(Y, nstates, 'gauss', ...
    'pi0', pi0, 'trans0', trans0, 'emission0',...
    emission0, 'verbose', true, 'maxIter', maxIter);

dgmModel.localCPDs = {emission0};
dgmModel.localCPDs{1}.prior = hmmModel.emissionPrior; 
dgmModel.CPDs{1} = tabularCpdCreate(pi0(:), 'prior', hmmModel.piPrior(:)); 
dgmModel.CPDs{2} = tabularCpdCreate(trans0, 'prior', hmmModel.transPrior); 

fprintf('\nDGM\n'); 
dgmModel = dgmFitEm(dgmModel, [], 'localev', localev, ...
    'verbose', true, 'maxIter', maxIter);
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





