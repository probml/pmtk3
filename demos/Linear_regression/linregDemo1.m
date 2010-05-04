%% Linreg Demo
%% Make data
[xtrain, ytrain, xtest, ytestNoisefree, ytest] = polyDataMake('sampling','thibaux');
Xtrain = xtrain; Xtest = xtest;

%% Basic fitting
Xtrain1 = [ones(size(Xtrain,1),1) Xtrain];
w = Xtrain1 \ ytrain;
Xtest1 = [ones(size(Xtest,1),1) Xtest];
ypredTest = Xtest1*w;

%% Use pmtk functions to do same thing
model2 = linregFitComplex(Xtrain, ytrain, 'lambda', 0);
[ypredTest2, v2] = linregPredict(model2, Xtest);
assert(approxeq(ypredTest, ypredTest2))

model3 = linregFit(Xtrain, ytrain, 'lambda', 0);
[ypredTest3, v3] = linregPredict(model3, Xtest);
assert(approxeq(model2.w, model3.w))
assert(approxeq(model2.sigma2, model3.sigma2))
assert(approxeq(ypredTest, ypredTest3))
assert(approxeq(v2, v3))

%% Plot
figure;
scatter(xtrain,ytrain,'b','filled');
%plot(xtrain,ytrain, 'bo', 'linewidth', 3, 'markersize', 12);
hold on;
plot(xtest, ypredTest, 'k', 'linewidth', 3);
% plot subset of error bars
Ntest = length(xtest);
ndx = floor(linspace(1, Ntest, floor(0.05*Ntest)));
errorbar(xtest(ndx), ypredTest(ndx), sqrt(v(ndx)))
printPmtkFigure('linregDemo1')

%% Repeat with standardization
% This has no effect on the predictions in this case
% Be careful not to apply standardization to the column of 1s!
% Note that we use xtrain not Xtrain, and xtest not Xtest
[Xtrain, mu, sigma] = standardizeCols(xtrain);
Xtest = standardizeCols(xtest, mu, sigma);

model = linregFitComplex(Xtrain, ytrain, 'lambda', 0);
ypredTest = linregPredict(model, Xtest);

figure;
scatter(Xtrain(:,1),ytrain,'b','filled');
hold on;
plot(Xtest(:,1), ypredTest, 'k', 'linewidth', 3);
printPmtkFigure('linregWedge2Line');

