%% Fit a discrete HMM via hmmFit and dgmTrain, comparing the results
%
%%

% This file is from pmtk3.googlecode.com

setSeed(0); 
obsModel = [1/6 , 1/6 , 1/6 , 1/6 , 1/6 , 1/6  ;   
           1/10, 1/10, 1/10, 1/10, 1/10, 5/10 ];   
transmat = [0.95 , 0.05;
           0.10  , 0.90];
pi = [0.5, 0.5];
T = 30; 
%% sample data
nsamples = 1;
markov.pi = pi;
markov.A = transmat;
hidden = markovSample(markov, T, nsamples);
observed = zeros(1, T); 
for t=1:T
   observed(1, t) = sampleDiscrete(obsModel(hidden(t), :)); 
end
%% create the hmm model
nstates = size(obsModel, 1);
hmm.nObsStates = size(obsModel, 2); 
hmm.emission = tabularCpdCreate(obsModel);
hmm.nstates = nstates;
hmm.pi = pi;
hmm.A = transmat; 
hmm.type = 'discrete';
%% fit the hmm model on random data
%
fprintf('HMM\n'); 
hmmF = hmmFit(observed, nstates, 'discrete', 'verbose', true, ...
    'pi0', hmm.pi, 'trans0', hmm.A, 'emission0', hmm.emission); 
%% convert to a dgm
dgm = hmmToDgm(hmm, T); 
dgm.CPDs{1}.prior = hmmF.piPrior(:);
dgm.CPDs{2}.prior = hmmF.transPrior;
%% fit the dgm
fprintf('DGM\n'); 
dgm = dgmTrain(dgm, 'localev', permute(observed(:), [3 2 1]), 'verbose', true); 
%% compare results
assert(approxeq(hmmF.pi(:), dgm.CPDs{1}.T(:))); 
assert(approxeq(hmmF.A, dgm.CPDs{2}.T)); 
assert(approxeq(hmmF.emission.T, dgm.localCPDs{1}.T)); 


