%% Fit a mixture of Gaussians comparing mixGaussFit and dgmTrain
%
%%
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
%% fit using mixGaussFit
fprintf('Mix Gauss\n');
mixGauss = mixGaussFit(localEv, nstates, 'mu', mu0, 'Sigma', Sigma0,...
    'mixweight', mix0, 'doMap', true, 'verbose', true); 
%% create the initial dgm
G           = 0; % graph of a single node with one localCPD
CPD         = tabularCpdCreate(mix0');
localCPD    = condGaussCpdCreate(mu0, Sigma0, 'prior', mixGauss.prior); 
mixGaussDgm = dgmCreate(G, CPD, 'localCPDs', localCPD);
%% fit using dgmTrain
fprintf('DGM\n'); 
mixGaussDgm = dgmTrain(mixGaussDgm, 'localev', localEv, 'verbose', true);
%% compare results
assert(approxeq(mixGaussDgm.localCPDs{1}.mu, mixGauss.mu)); 
assert(approxeq(mixGaussDgm.localCPDs{1}.Sigma, mixGauss.Sigma)); 
assert(approxeq(mixGaussDgm.CPDs{1}.T(:), mixGauss.mixweight(:)));
