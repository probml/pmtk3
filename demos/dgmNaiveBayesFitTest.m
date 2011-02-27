%% Compare dgmTrain and naiveBayesFit
%
%%

% This file is from pmtk3.googlecode.com

function dgmNaiveBayesFitTest
C = 5;  % 5 classes
d = 20; % each data case will be 20 dimensional 
K = 2;  % binary data
ncases = 100; 
%% generate some data
X = randi(K, [ncases, d]); 
y = randi(C, [ncases, 1]); 
%% fit using naive Bayes
pseudoCounts = 1; 
nb = naiveBayesFit(X-1, y, pseudoCounts); 
%% create an equivalent dgm
G = zeros(d+1, d+1);
for i=1:d
    G(1, i+1) = 1;
end
nstates(1) = C; 
nstates(2:d+1) = K; 
CPDs = mkRndTabularCpds(G, nstates, 'prior', pseudoCounts); 
CPDs{1}.prior = 0; % 1
dgm = dgmCreate(G, CPDs); 
%% fit the dgm
dgm = dgmTrainFullyObs(dgm, [y, X]); 
%% compare the results
assert(approxeq(nb.classPrior(:), dgm.CPDs{1}.T(:))); 
for i=1:d
   assert(approxeq(nb.theta(:, i), dgm.CPDs{i+1}.T(:, 2)));  
end
end
