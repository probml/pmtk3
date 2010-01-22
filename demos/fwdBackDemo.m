K = 3;
%initDist= [1 0 0]'; % start in state 1
initDist= normalize(ones(3,1)); % could start anywhere

% Left to right HMM 1->2->3 where 3 has a self-loop with prob 1
% So stationary distribution of the unobserved chain is [0 0 1]
p = 0.9; q=1-p;
transmat = [q p 0;
	    0 q p;
	    0 0 1];
T = 7;
%obslik = ones(K, T); % non-informative observations
obslik = repmat([0.5 0.3 0.2]', 1, T); % noisy obs
nsamples = 1000;

% check that samples converge to true marginals

samples = hmmSamplePost(initDist, transmat, obslik, nsamples);
gamma = hmmFwdBack(initDist, transmat, obslik);
path = hmmViterbi(initDist, transmat, obslik)

for t=1:T
  belApprox(:,t) = normalize(hist(samples(t,:),1:K));
end
gamma
belApprox
