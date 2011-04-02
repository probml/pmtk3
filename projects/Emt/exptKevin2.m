
%learnExpt(name, model, numOfMix, Dz, seed)
%[mseC, mseD, entrpyD] = imputeExpt_2(imputeName, name, model, numOfMix, Dz, seed)

clear all
dataName = 'ases4';
%dataName = 'ases';
Nfolds = 1;
methodNames = {};
maxIters = 100;
pcTrain = 0.5; pcTest = 0.5;
%pcTrain = 0.1; pcTest = 0.7;
for seed = 1:Nfolds
  m = 0;
 
  Ks = [1,5,10,20,40];
  for kk=1:numel(Ks)
    K = Ks(kk);
    m = m + 1;
    [params, params0, dataTrain] = learnExpt(dataName, 'indDisGmmDiag', K, 0, seed, maxIters, pcTrain);
    [~,~, eD(m,seed), dataTest] = imputeExpt_2('randomDiscrete', dataName, 'indDisGmmDiag', K, 0, seed, 1-pcTest);
    methodNames{m} = sprintf('mix%d', K);
    [D, Ntrain] = size(dataTrain.discrete)
    [D2, Ntest] = size(dataTest.discreteTest)
  end
  
 
   Dzs = [1, 5,10,20,40];
   for kk=1:numel(Dzs)
     Dz = Dzs(kk);
     m = m + 1;
     learnExpt(dataName, 'disGaussFA', 0, Dz, seed, maxIters, pcTrain);
     [~, ~, eD(m,seed)] = imputeExpt_2('randomDiscrete', dataName, 'disGaussFA', 0, Dz, seed, 1-pcTest);
     methodNames{m} = sprintf('cFA%d', Dz);
   end
  
end

figure;
if Nfolds==1
  plot(eD, 'x', 'markersize', 12, 'linewidth', 2)
  axis_pct
else
  boxplot(eD');
end
set(gca,'xtick', 1:numel(methodNames), 'xticklabel', methodNames);
ylabel('error');
title(sprintf('EMT: %s,D=%d,Ntr=%d,Nte=%d', dataName, D, Ntrain, Ntest))

