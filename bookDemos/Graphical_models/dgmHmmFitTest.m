%% Fit an HMM and an equivalent DGM and make sure the results agree
setSeed(0); 
%% sample data
nstates   = 5;
d         = 2; 
T         = 10; 
nsamples  = 2; 
hmmSource = mkRndGaussHmm(nstates, d); 
[Y, Z] = hmmSample(hmmSource, T, nsamples); 
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
pi0 = normalize(rand(1, nstates)); 
trans0 = normalize(rand(nstates, nstates), 2); 
Sigma0 = zeros(d, d, nstates); 
for i=1:nstates
    Sigma0(:, :, i) = randpd(d) + 2*eye(d); 
end
mu0 = randn(d, nstates); 
emission0 = condGaussCpdCreate(mu0, Sigma0); 

hmmModel = hmmFitEm(Y, nstates, 'gauss', ...
    'pi0', pi0, 'trans0', trans0, 'emission0', emission0, 'maxIter', 2);
dgmModel.localCPDs = {emission0};
dgmModel.CPDs{1} = tabularCpdCreate(pi0(:)); 
dgmModel.CPDs{2} = tabularCpdCreate(trans0); 

dgmModel = dgmFitEm(dgmModel, [], 'localev', localev, 'verbose', true);

