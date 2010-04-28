% demo script to show Subset of Data (SD), Subset of Regressors (SR) and
% Projected Process (PP) approximations to GPR described in chapter 8 on the
% Boston Housing data

% The Boston housing data set was originally published by Harrison, D. and
% Rubinfeld, D. L., Hedonic housing prices and the demand for clean air, 
% Journal of Environmental Economics and Management 5, 81-102 (1978) and is
% publicly available at the UCI database "UCI Repository of machine learning
% databases", http://www.ics.uci.edu/~mlearn/MLRepository.html and DELVE
% http://www.cs.utoronto.ca/~delve
%
% (C) Copyright 2005, 2006 by Chris Williams (2006-03-29)

if isempty(regexp(path,['gpml' pathsep]))
  cd ..; w = pwd; addpath([w, '/gpml']); cd gpml-demo    % add code dir to path
end

hold off
clear
clc

disp('This demonstration illustrates the use of three approximate methods for')
disp('GPR, namely the subset of datapoints (SD), subset of regressors (SR)')
disp('and projected process (PP) methods.')
disp(' ');
disp('We use the Boston housing data of Harrison, D. and Rubinfeld, D. L.,')
disp('Journal of Environmental Economics and Management 5, 81-102 (1978).')
disp('This dataset has 13 input variables and one output target. A split of')
disp('455 training points and 51 test points is used. The data has been')
disp('scaled so that each variable has approximately zero mean and unit')
disp('variance.')
disp(' ')
disp('We use Gaussian process regression with a squared exponential')
disp('covariance function, and allow a separate lengthscale for each input')
disp('dimension, as in eqs. 5.1 and 5.2 of Rasmussen and Williams (2006).')
disp(' ')
disp('Press any key to continue')
pause;

disp(' ')
disp('The training and test data is contained in the file data_boston.mat')
disp('The raw training data is in the input matrix X (455 by 13) and the')
disp('target vector y (455 by 1). First, load the data')
disp(' ')
disp('  load data_boston;')
load data_boston;

disp('the data has been scaled to zero mean and unit variance')
disp('over the training and test data');

[n,D]=size(X);
nstar = size(Xstar,1);

% compute error of mean(y) predictor

diff = ystar - ones(nstar,1)*mean(y);
mse_dumb=sum(diff.^2)/nstar;
vdumb = var(y)*ones(nstar,1);
pll_dumb = (-0.5*sum(log(2*pi*vdumb)) - 0.5*sum((diff.*diff)./vdumb))/nstar;

disp(' ')
disp('  m = 200;  % choose size of the subset, m<=n')
m = 200;  % choose size of the subset, m<=n
disp(' ')
disp('A random subset of the training data points are selected using the')
disp('randperm function. This set is of size m.')
disp(' ')

% now select random training set of size m
rand('state',0);
disp('  perm = randperm(n);')
perm = randperm(n);
disp('  INDEX = perm(1:m);')
INDEX = perm(1:m);
disp('  Xm = X(INDEX,:);')
Xm = X(INDEX,:);
disp('  ym = y(INDEX);')
ym = y(INDEX);

disp(' ')
disp('We use a covariance function made up of the sum of a squared')
disp('exponential (SE) covariance term with ARD, and independent noise.')
disp('Thus, the covariance function is specified as follows:')
disp(' ')
disp('  covfunc = {''covSum'', {''covSEard'',''covNoise''}};')
covfunc = {'covSum', {'covSEard','covNoise'}};

disp(' ');
disp('The hyperparameters are stored as')
disp(' ')
disp('  logtheta = [log(ell_1), log(ell_2), ... log(ell_13), log(sigma_f), log(sigma_n)]')
disp(' ')
disp('(as D = 13), and are initialized to')
disp(' ')
disp('  logtheta0 = [0 0 ... 0 0 -1.15]')
disp(' ');
disp('Note that the noise standard deviation is set to exp(-1.15)')
disp('corresponding to a noise variance of 0.1.')
disp(' ')
disp('The hyperparameters are trained by maximizing the approximate marginal')
disp('likelihood of the SD method as per eq. 8.31, which simply computes the')
disp('marginal likelihood of the subset of size m.')
disp(' ')
disp('Press any key to optimize the approximate marginal likelihood.')
pause;

% train hyperparameters
logtheta0 = zeros(D+2,1);              % starting values of log hyperparameters
logtheta0(D+2) = -1.15;                 % starting value for log(noise std dev)

disp(' ')
disp('  logtheta = minimize(logtheta0, ''gpr'', -100, covfunc, Xm, ym);')
disp(' ')
logtheta = minimize(logtheta0, 'gpr', -100, covfunc, Xm, ym);

disp(' ')
disp('Predictions can now be made:') 
disp(' ')
disp('(1) using the SD method, which is implemented by calling gpr.m with the')
disp('    appropriate subset of the training data')
disp('(2) using the SR method,')
disp('(3) using the PP method.')
disp(' ')
disp('The SR and PP methods are implemented in the function  gprSRPP.m')
disp(' ')
disp('For comparison we also make predictions using gpr.m on the full')
disp('training dataset, and a dumb predictor that just predicts the mean and')
disp('variance of the training data.')
disp(' ')
disp('Press any key to make the predictions.')
pause;

% now make predictions: SD method

disp(' ')
disp('  [fstarSD S2SD] = gpr(logtheta, covfunc, Xm, ym, Xstar); % SD method')
[fstarSD S2SD] = gpr(logtheta, covfunc, Xm, ym, Xstar);

resSD = fstarSD-ystar;  % residuals
mseSD = mean(resSD.^2);
pllSD = (-0.5*sum(log(2*pi*S2SD)) - 0.5*sum((resSD.*resSD)./S2SD))/nstar;


% now make predictions: SR and PP methods

disp('  [fstarSRPP S2SR S2PP] = gprSRPP(logtheta, covfunc, X, INDEX, y, Xstar); % SR,PP')
[fstarSRPP S2SR S2PP] = gprSRPP(logtheta, covfunc, X, INDEX, y, Xstar); 

resSR = fstarSRPP-ystar;
mseSR = sum(resSR.^2)/nstar;
msePP = mseSR;
pllSR = -0.5*mean(log(2*pi*S2SR)+resSR.^2./S2SR);
pllPP = -0.5*mean(log(2*pi*S2PP)+resSR.^2./S2PP);

% for comparison, make predictions with the full training dataset

[fstar S2] = gpr(logtheta, covfunc, X, y, Xstar);

res = fstar-ystar;  % residuals
mse = mean(res.^2);
pll = -0.5*mean(log(2*pi*S2)+res.^2./S2);


disp(' ')
disp('The test results are:')

fprintf(1,'mse_full %g\t pll_full %g\n', mse, pll);
fprintf(1,'mse_SD   %g\t pll_SD   %g\n', mseSD, pllSD);
fprintf(1,'mse_SR   %g\t pll_SR   %g\n', mseSR, pllSR);
fprintf(1,'mse_PP   %g\t pll_PP   %g\n', msePP, pllPP);
fprintf(1,'mse_dumb %g\t pll_dumb %g\n', mse_dumb, pll_dumb);

disp(' ')
disp('where mse denotes mean squared error and pll denotes predictive log')
disp('likelihood. A higher (less negative) pll is more desirable. Note that')
disp('the mse for the SR and PP methods is identical as expected. The SR and')
disp('PP methods outperform SD on mse, and are close to the full mse. On pll,')
disp('the PP method does slightly better than the full predictor, followed by')
disp('the SD and SR  methods.')

disp(' ')
disp('Press any key to end.')
pause

