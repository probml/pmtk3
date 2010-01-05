%% Bernoulli mixture model for mnist digits

setSeed(0);
binary = true;
Ntrain = 5000;
Ntrain = 1000
Ntest = 1000;
Kvalues = 1:20; % A range of values that covers the "natural" choice well
Kvalues = [2 10]

%Kvalues = 10; % The "natural" choice given what we know of the data
%Kvalues = 2; % Something small and simple, yet nontrivial, for testing and debugging
[Xtrain,Xtest,ytrain,ytest] = setupMnist(binary, Ntrain, Ntest);
Xtrain = double(Xtrain); Xtest = double(Xtest);
[n,d] = size(Xtrain);
NK = length(Kvalues);
logp = zeros(1,NK);
bicVal = zeros(1,NK);
for ki=1:NK
  K = Kvalues(ki);
  % training
  fprintf('Fitting K = %d \n', K)
  % A few pmtk1 specific calls to set things up
  MixBernoulli = MixDiscrete('-nmixtures', K, '-nstates', 2, '-support', 0:1);
  mixingDistrib = mkRndParams(MixBernoulli.mixingDistrib);
  mixingWeights = mixingDistrib.T;
  MixBernoulli.mixingDistrib = initPrior(MixBernoulli.mixingDistrib);
  mixAlpha = MixBernoulli.mixingDistrib.prior.alpha;
  % This "p" is nStates * nDistributions * nMixingComponents
  p = zeros(2,d,K);
  % The Dirichlet prior on each mixing component
  distPrior = zeros(2,K);
  for k=1:K
    % Again, pmtk1.  Can easily replace with the appropriate pmtk2 function call when ready
    mixingDist = mkRndParams(MixBernoulli.distributions{k}, d);
    p(:,:,k) = mixingDist.T;
    mixingDist = initPrior(MixBernoulli.distributions{k});
    distPrior(:,k) = mixingDist.prior.alpha;
  end
  [pFit{ki}, mixingWeightsFit{ki}] = ...
    EMforDiscreteMM(p, distPrior, mixingWeights, mixAlpha, Xtrain, '-maxItr', 20);

  % testing
  for k=1:K
    MixBernoulli.distributions{k}.T = pFit{ki}(:,:,k);
  end
  MixBernoulli.mixingDistrib.T = mixingWeightsFit{ki};
  logp(ki) = sum(logprob(MixBernoulli, Xtest));
  nParams = K*d + K-1;
  bicVal(ki) = -2*logp(ki) + nParams*log(n);
end
  %MixBernoulli = fit(MixBernoulli, Xtrain); Way too slow

for ki=1:NK
  K =Kvalues(ki);
  figure();
  [ynum, xnum] = nsubplots(K);
  if K==10
    ynum = 2; xnum = 5;
  end
  pK = pFit{ki}; mixingWeightsK = mixingWeightsFit{ki};
  for j=1:K
    subplot(ynum, xnum, j);
    imagesc(reshape(pK(2,:,j), 28, 28)); colormap('gray');
    title(sprintf('%1.2f', mixingWeightsK(j)));
    axis off
  end
  printPmtkFigure(sprintf('MnistMix%dBernoullis', K));
end

figure(); plot(Kvalues, bicVal);
title(sprintf('Minimum achieved for K = %d', argmin(bicVal)));
printPmtkFigure('MnistBICvsKplot');

[sortedBicVal, sortedBicIdx] = sort(bicVal);
[colvec(Kvalues(sortedBicIdx)), colvec(sortedBicVal)]
