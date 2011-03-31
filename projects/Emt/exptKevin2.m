
%learnExpt(name, model, numOfMix, Dz, seed)
%[mseC, mseD, entrpyD] = imputeExpt_2(imputeName, name, model, numOfMix, Dz, seed)

clear all
dataName = 'newsgroup'; %'newsgroups'; % 'ases';
Nfolds = 1;
methodNames = {};
for seed = 1:Nfolds
  m = 0;
 
  m=m+1;
 K = 1;
 [params, params0, data] = learnExpt(dataName, 'indDisGmmDiag', K, 0, seed);
  [~,~, eD(m,seed)] = imputeExpt_2('randomDiscrete', dataName, 'indDisGmmDiag', K, 0, seed);
  methodNames{m} = 'mix1';
  
  m=m+1;
  K = 5;
  learnExpt(dataName, 'indDisGmmDiag', K, 0, seed);
  [~,~, eD(m,seed)] = imputeExpt_2('randomDiscrete', dataName, 'indDisGmmDiag', K, 0, seed);
  methodNames{m} = 'mix5';
  
  m=m+1;
  K = 10;
  learnExpt(dataName, 'indDisGmmDiag', K, 0, seed);
  [~,~, eD(m,seed)] = imputeExpt_2('randomDiscrete', dataName, 'indDisGmmDiag', K, 0, seed);
  methodNames{m} = 'mix10';
  
  m=m+1;
  Dz = 5;
  learnExpt(dataName, 'disGaussFA', 0, Dz, seed);
  [~, ~, eD(m,seed)] = imputeExpt_2('randomDiscrete', dataName, 'disGaussFA', 0, Dz, seed);
  methodNames{m} = 'catFA5';
  
   m=m+1;
   Dz = 10;
 learnExpt(dataName, 'disGaussFA', 0, Dz, seed);
  [~, ~, eD(m,seed)] = imputeExpt_2('randomDiscrete', dataName, 'disGaussFA', 0, Dz, seed);
  methodNames{m} = 'catFA10';
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
title(dataName)
