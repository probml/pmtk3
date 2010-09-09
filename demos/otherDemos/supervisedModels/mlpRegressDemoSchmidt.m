%% MLP Regression Demo
% Based on Mark Schmidt's Demo from
% http://people.cs.ubc.ca/~schmidtm/Software/minFunc/minFunc.html#8
%%

% This file is from pmtk3.googlecode.com

setSeed(0);
nVars = 1;
nInstances = 400;
options.Display = 'iter';
options.MaxIter = 50;
[X,y] = makeData('regressionNonlinear',nInstances,nVars);
lambda = 0;
model = mlpRegressFitSchmidt(X, y, [10], lambda, options);


figure;
Xtest = [-5:.05:5]';
[yhat, v] = mlpRegressPredictSchmidt(model, Xtest);
plot(X,y,'.');
hold on
h=plot(Xtest,yhat,'g-');
set(h,'LineWidth',3);

%{
figure;
plot(X,y,'.');
hold on
h=plot(Xtest,yhat,'g-');
set(h,'LineWidth',3);
N = length(Xtest);
ndx = 1:5:N;
h=errorbar(Xtest(ndx), yhat(ndx), 2*sqrt(v(ndx)));
set(h, 'color', 'g');
legend({'Data','Neural Net'});
%}
