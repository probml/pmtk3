%% Simple test of hmmFit with tied mix Gauss observations
%
%%
setSeed(0); 
loadData('data45');
data = [train4'; train5'];
d = 13;
nstates = 3;
nmix    = 4; % must specify nmix

  prior.mu    = zeros(1, d);
   prior.Sigma = 2*eye(d);
   prior.k     = 0.01;
    prior.dof   = d + 1;   
    prior.pseudoCounts = 3*ones(nstates, nmix); 


model = hmmFit(data, nstates, 'mixGaussTied', 'verbose', true, ...
    'nRandomRestarts', 3, 'nmix', nmix, 'piPrior', 10*ones(1, nstates), ...
    'transPrior', 10*ones(nstates), 'emissionPrior', prior);


