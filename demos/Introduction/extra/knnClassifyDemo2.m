%% Classify using KNN
%
%%
function knnClassifyDemo2()


%% load data
tmp = dlmread('knnClassify3CTrain.txt');
Xtrain = tmp(:,1:2); ytrain = tmp(:,3);
tmp = dlmread('knnClassify3CTest.txt');
Xtest = tmp(:,1:2); ytest = tmp(:,3);
Ntest = size(Xtest,1);
Ntrain = size(Xtrain,1)



%% Classify and plot predictions on test data
Ks = [1 5 10 20 50 100 120];
for ki=1:length(Ks)
  K = Ks(ki);
  model = knnFit(Xtrain, ytrain, K); 
  [ypred] = knnPredict(model, Xtest);
  err = find(ypred(:) ~= ytest(:));
  nerrors = length(err);
  errRateTest(ki) = nerrors/Ntest;
 
  % compute error on training set
  
  [ypred] = knnPredict(model, Xtrain);
  err = find(ypred(:) ~= ytrain(:));
  nerrors = length(err);
  errRateTrain(ki) = nerrors/Ntrain;
end

figure; 
plot(Ks, errRateTrain, 'ro-', Ks, errRateTest, 'ko-');
return

end