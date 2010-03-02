
%% Make data
[xtrain, ytrain, xtest, ytestNoisefree, ytest] = polyDataMake('sampling','thibaux');
Xtrain = xtrain; Xtest = xtest;

%% Basic fitting
Xtrain1 = [ones(size(Xtrain,1),1) Xtrain];
w = Xtrain1 \ ytrain;
Xtest1 = [ones(size(Xtest,1),1) Xtest];
ypredTest = Xtest1*w;

%% Use pmtk functions to do same thing
model = linregFit(Xtrain, ytrain);
[ypredTest2, v] = linregPredict(model, Xtest);
assert(approxeq(ypredTest, ypredTest2))

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

model = linregFit(Xtrain, ytrain);
ypredTest = linregPredict(model, Xtest);

figure;
scatter(Xtrain(:,1),ytrain,'b','filled');
hold on;
plot(Xtest(:,1), ypredTest, 'k', 'linewidth', 3);

