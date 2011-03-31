
%learnExpt(name, model, numOfMix, Dz, seed)
%[mseC, mseD, entrpyD] = imputeExpt_2(imputeName, name, model, numOfMix, Dz, seed)

clear all
dataName = 'newsgroup'; %'newsgroups'; % 'ases';
for i = 1:1
  K = 40;
  dataTrain = learnExpt(dataName, 'indDisGmmDiag', K, 0, i);
  [mC, mD(1,i), eD(1,i), dataTest] = imputeExpt_2('randomDiscrete', dataName, 'indDisGmmDiag', K, 0, i);
  Dz = 40;
  dataTrain2 = learnExpt(dataName, 'disGaussFA', 0, Dz, i);
  [mC, mD(2,i), eD(2,i), dataTest2] = imputeExpt_2('randomDiscrete', dataName, 'disGaussFA', 0, Dz, i);
end
figure;
boxplot(eD');
set(gca,'xtick',[1 2], 'xticklabel',{'MixModel','FA'});
ylabel('Entropy');
title(dataName)


%{
%%%%

i = 1;
Dz = 40;
[params, params0, dataTrain2] = learnExpt(dataName, 'disGaussFA', 0, Dz, i, 1);
imputeExpt_2('randomDiscrete', dataName, 'disGaussFA', 0, Dz, i);
  

%%%%

% Generate data 

% Train
seed = 1; name = 'newsgroup';
setSeed(seed);
[dataTrain, nClass] = processData(name, struct('ratio',0.1));

% Test
 setSeed(seed);
[dataTest, nClass] = processData(name, []);
imputeName = 'randomDiscrete';
missProbD = 0.3;
% create missing data in the test se
ydT = dataTest.discreteTestTruth;
testData.discrete = ydT;
if ~isempty(ydT)
  miss = rand(size(ydT))<missProbD;
  testData.discrete(miss) = NaN;
end

  
folder = '/home/kpmurphy/Dropbox/Students/Emt/datasets';
train.labels = dataTrain.discrete'; % 461 cases x 93 words
test.labels = ydT';
test.labelsMasked = testData.discrete';
missingMask = miss';
fname = fullfile(folder, 'a3newsgroupsTrainTest.mat')
save(fname, 'train', 'test', 'missingMask')
%}
