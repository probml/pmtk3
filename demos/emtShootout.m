% This is a simplified version of 'discreteDensityModelsShootout'
% It should give the same results as 'exptKevin2'

% Stop it from being included in list of automatic demos
%PMTKinprogress

%% Data
% data.discrete is D*N where discrete(d,n) in {1..nClass(d)}

clear all

seed = 1;
dataName = 'ases4';
pcTrain = 0.5; pcTest = 0.5;
missProbD = 0.3;
setSeed(seed);
[dataTrain, nClass] = processData(dataName, struct('ratio',pcTrain));

  
setSeed(seed);
[dataTest, nClass2] = processData(dataName, struct('ratio',1-pcTest));
ydT = dataTest.discreteTestTruth;
miss = rand(size(ydT))<missProbD;
testData.discrete(miss) = NaN;
      
% Convert to KPM format 
% labels is N*D, where labels(n,d) in {1..Nstates(d)} or NaN
train.labels = dataTrain.discrete';
test.labels = dataTest.discreteTestTruth';
%test.labelsMasked = testData.discrete';
test.missingMask = miss';
test.labelsMasked  = test.labels;
test.labelsMasked(test.missingMask) = nan;
Nstates = nClass;


%% Models/ methods

methods = [];
m = 0;

m = m + 1;
methods(m).modelname = 'indep';
methods(m).fitFn = @(labels) discreteFit(labels);
methods(m).logprobFn = @(model, labels) discreteLogprob(model, labels);
methods(m).predictMissingFn = @(model, labels) discretePredictMissing(model, labels);


Ks = [1,5,10,20,40];
%Ks = [1,5];
for kk=1:numel(Ks)
  K = Ks(kk); % num mix components
  m = m + 1;
  alpha = 1.1;
  %methods(m).modelname = sprintf('mixK%d,a%2.1f', K, alpha);
  methods(m).modelname = sprintf('mix%d', K);
  methods(m).fitFn = @(labels) mixDiscreteFit(labels, K, 'maxIter', 30, ...
    'verbose', false, 'alpha', 1.1);
  methods(m).logprobFn = @(model, labels) mixDiscreteLogprob(model, labels);
  methods(m).predictMissingFn = @(model, labels) mixDiscretePredictMissing(model, labels);
end 



Ks = [1,5,10,20,40];
%Ks = [1,5];
for kk=1:numel(Ks)
  K = Ks(kk); % size of latent space (Dz)
  m = m + 1;
  methods(m).modelname = sprintf('dFA-%d', K);
  methods(m).fitFn = @(labels) catFAfit(labels, [],  K,  'nClass', Nstates, ...
    'maxIter', 30, 'verbose', true, 'nClass', Nstates);
  methods(m).logprobFn = @(model, labels) nan(size(labels,1),1);
  methods(m).predictMissingFn = @(model, labels) catFApredictMissing(model, labels, []);
end



Nmethods = numel(methods);
[Ntrain, Nnodes] = size(train.labels);
[Ntest, Nnodes2] = size(test.labels);
fold = 1;
Nfolds = 1;

models = cell(1, Nmethods);
methodNames = cell(1, Nmethods);
for m=1:Nmethods
  methodNames{m} = sprintf('%s', methods(m).modelname);
  fprintf('fitting %s\n', methodNames{m});
  models{m} = methods(m).fitFn(train.labels);
end


ll = zeros(1, Nmethods);
imputationErr = zeros(1,Nmethods);
for m=1:Nmethods
  fprintf('evaluating %s\n', methodNames{m});
  ll(m) = sum(methods(m).logprobFn(models{m}, test.labels))/Ntest;
  
  pred = methods(m).predictMissingFn(models{m}, test.labelsMasked);
  % pred is N * D * K
  
  % Emt's evaluation code
  nClass = Nstates;
  yd = test.labelsMasked';
  ydT = test.labels';
  ydT_oneOfM = encodeDataOneOfM(ydT, nClass, 'M');
  yd_oneOfM = encodeDataOneOfM(yd, nClass, 'M');
  N = size(yd_oneOfM,2);
  miss = isnan(yd_oneOfM);
  pred2 = permute(pred, [3 2 1]); % K D N
  Ntest = N;
  pred3 = reshape(pred2, [sum(nClass) Ntest]); % KD * N
  %yhatD = reshape(pred+eps, [Ntest sum(nClass)])';
  
  
  % if predict [0 0], replace with eps
  M = nClass;
  for d = 1:length(M)
    idx = sum(M(1:d-1))+1:sum(M(1:d));
    p1 = pred3(idx,:);
    if ~isempty(find(sum(p1,2) == 0))
      p1 = p1 + eps;
      p1 = bsxfun(@times, p1, 1./sum(p1));
    end
    pred3(idx,:) = p1;
  end
  
  yhatD = pred3;
  entrpyD = -sum(ydT_oneOfM(miss).*log2(yhatD(miss)))/(Ntest*length(nClass))
  %entrpyD = -sum(ydT_oneOfM(miss).*log2(yhatD(miss)))/(sum(miss(:)));
  
  imputationErr(m) =  entrpyD;
end
loglik_models(fold, :) = ll;
imputation_err_models(fold, :) = imputationErr;





%% Plot performance




% imputation error
figure;
ndx = 1:Nmethods 
if Nfolds==1
  plot(imputation_err_models(ndx), 'x', 'markersize', 12, 'linewidth', 2)
  axis_pct
else
  boxplot(imputation_err_models(:, ndx))
end
set(gca, 'xtick', 1:numel(ndx))
set(gca, 'xticklabel', methodNames(ndx))
%xticklabelRot(methodNames(ndx), -45);
title(sprintf('KPM imputation error on %s, %5.3fpc missing, D=%d, Ntr=%d, Nte=%d', ...
  dataName, missProbD, Nnodes, Ntrain, Ntest))


