%% Fit a mixture of Gaussians comparing mixModelFit and dgmTrain
%
%%

% This file is from pmtk3.googlecode.com

setSeed(0);
nstates = 3; 
d       = 10; 
nobs    = 100; 
%% initialize both models the same
mu0     = randn(d, nstates); 
Sigma0  = zeros(d, d, nstates);
for i=1:nstates
   Sigma0(:, :, i) = randpd(d) + 2*eye(d);  
end
mix0 = normalize(rand(1, nstates)); 
%% random data
localEv = randn(nobs, d); 
%% fit using mixModelFit
fprintf('Mix Gauss\n');
initParams.mu = mu0;
initParams.Sigma = Sigma0;
initParams.mixWeight = mix0; 
%mixGauss = mixModelFit(localEv, nstates, 'gauss', 'initParams', initParams, 'verbose', true, 'mixPrior', 'none');
mixGauss = mixGaussFit(localEv, nstates, 'initParams', initParams, 'verbose', true, 'mixPrior', 'none');
%% create the initial dgm
G           = 0; % graph of a single node with one localCPD
CPD         = tabularCpdCreate(mix0');
localCPD    = condGaussCpdCreate(mu0, Sigma0, 'prior', mixGauss.cpd.prior); 
mixGaussDgm = dgmCreate(G, CPD, 'localCPDs', localCPD);
%% fit using dgmTrain
fprintf('DGM\n'); 
mixGaussDgm = dgmTrain(mixGaussDgm, 'localev', localEv, 'verbose', true);
%% compare results
assert(approxeq(mixGaussDgm.localCPDs{1}.mu, mixGauss.cpd.mu)); 
assert(approxeq(mixGaussDgm.localCPDs{1}.Sigma, mixGauss.cpd.Sigma)); 
assert(approxeq(mixGaussDgm.CPDs{1}.T(:), mixGauss.mixWeight(:)));
