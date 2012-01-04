% Sequentially compute N best list for an HMM
% See "Sequentially finding the N-Best List in Hidden Markov Models"
% Nilsson and Goldberger, IJCAI 2001
% We do the example in sec 3.2

%PMTKinprogress

initDist = [0.6; 0.4];
transmat = [0.6 0.4; 0.2 0.8];
obsmat = [0.9 0.1; 0.3 0.7];
y = [1 1 2 2 2 2 1 1 2 2]; % n=1, y=2
CPT = tabularCpdCreate(obsmat);
logB = mkSoftEvidence(CPT, y); 
[logB, scale] = normalizeLogspace(logB'); 
softev = exp(logB'); % (k,t)

%[gamma, alpha, beta, loglik] = hmmFwdBack(initDist, transmat, softev);
%[gamma2, alpha2, beta2] = hmmFwdBackMaxProduct(initDist, transmat, softev);
[ff, logmaxprob] = hmmFwdBackMaxProduct(initDist, transmat, softev);