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
%% FULLY OBSERVED HMM CASE
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

%%
%% UNOBSERVED HMM CASE
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
%dgmModel.infEngine = 'libdaiJtree'; 
dgmModel = dgmFitEm(dgmModel, [], 'localev', localev, ...
    'verbose', true, 'maxIter', maxIter);
% compare results
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


%% ALARM NETWORK
fprintf('alarm network\n');
dgm = mkAlarmDgm();
data = randi(2, [20, 37]); 
data(1:3:end) = 0;
data = sparse(data); 
dgm.infEngine = 'libdaiJtree';
dgm = dgmFitEm(dgm, data, 'verbose', true, 'maxIter', 5); 


%% MIXTURE OF GAUSSIANS
% note loglik values won't agree since mixGaussEm /N and does not include
% normalization constant for log prior
setSeed(0);
nstates = 3; 
d       = 10; 
nobs    = 100; 
mu      = randn(d, nstates); 
Sigma = zeros(d, d, nstates);
for i=1:nstates
   Sigma(:, :, i) = randpd(d) + 2*eye(d);  
end
mix = normalize(rand(1, nstates)); 
localEv = randn(nobs, d); 
mixGauss = mixGaussFitEm(localEv, nstates, 'mu', mu, 'Sigma', Sigma,...
    'mixweight', mix, 'doMap', true, 'maxIter', 5, 'verbose', false); 

prior.mu = mixGauss.prior.m0;
prior.Sigma = mixGauss.prior.S0;
prior.dof = mixGauss.prior.nu0;
prior.k = mixGauss.prior.kappa0; 

G = 0; % graph of a single node with one localCPD
CPD = tabularCpdCreate(mix');
localCPD = condGaussCpdCreate(mu, Sigma, 'prior', prior); 
mixGaussDgm = dgmCreate(G, CPD, 'localCPDs', localCPD);

mixGaussDgm = dgmFitEm(mixGaussDgm, [], 'localev', localEv, 'verbose', false, 'maxIter', 5);
assert(approxeq(mixGaussDgm.localCPDs{1}.mu, mixGauss.mu)); 
assert(approxeq(mixGaussDgm.localCPDs{1}.Sigma, mixGauss.Sigma)); 
assert(approxeq(mixGaussDgm.CPDs{1}.T(:), mixGauss.mixweight(:)));

