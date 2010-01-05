
% Make data
n = 21;
xtrain = linspace(0,20,n)';
xtest = [0:0.1:20]';
sigma2 = 4;
w = [-1.5; 1/9];
fun = @(x) w(1)*x + w(2)*x.^2;
ytrain = feval(fun, xtrain) + randn(size(xtrain,1),1)*sqrt(sigma2);
ytestNoisefree = feval(fun, xtest);
Xtrain = xtrain; Xtest = xtest;


%% Basic
Xtrain = [ones(size(Xtrain,1),1) Xtrain];
w = Xtrain \ ytrain;
Xtest = [ones(size(Xtest,1),1) Xtest];
ypredTest = Xtest*w;

figure;
scatter(Xtrain(:,2),ytrain,'b','filled');
hold on;
plot(Xtest(:,2), ypredTest, 'k', 'linewidth', 3);


%% With standardization
Xtrain = xtrain; Xtest = xtest;


% Preprocess train
[Xtrain, mu, sigma] = standardizeCols(Xtrain);
w = linregL2Fit(Xtrain, ytrain, 0);
Xtest = standardizeCols(Xtest, mu, sigma);
ypredTest = linregPredict(w, Xtest);

figure;
scatter(Xtrain(:,1),ytrain,'b','filled');
hold on;
plot(Xtest(:,1), ypredTest, 'k', 'linewidth', 3);

