% demo script to illustrate use of gpr.m on 6-d input data
% using David MacKay's robot arm problem.

% MacKay (1992) considered the nonlinear robot arm mapping problem 
% f(x_1,x_2) = r_1 cos (x_1) + r_2 cos(x_1 + x_2)
% where x_1 was chosen randomly in [-1.932, -0.453] and
% x_2 was chosen randomly in [0.534, 3.142], and 
% r_1 = 2.0, r_2 = 1.3. The target values were obtained
% by adding Gaussian noise of variance 0.0025 to f(x_1,x_2)

% Neal (1996) added four further inputs, two of which (x_3 and x_4) were 
% copies of x_1 and x_2 corrupted by additive Gaussian noise of standard 
% deviation 0.02,  and two of which (x_5 and x_6) were N(0,1) 
% Gaussian noise variables.

% This dataset was used in Williams and Rasmussen (1996) to 
% demonstrate Gaussian process regression and automatic
% relevance determination (ARD).

% Refs:
% D. J. C. MacKay, A Practical Bayesian Framework for
% Backpropagation Networks, Neural Computation 4, 448-472, (1992)
%
% R. M. Neal, Bayesian Learning for Neural Networks, Springer, (1996)
%
% C. K. I. Williams and C. E. Rasmussen
% Gaussian Processes for Regression, Advances in Neural
% Information Processing Systems 8, pp 514-520, MIT Press (1996).
%
% (C) Copyright 2005, 2006 by Chris Williams (2006-03-29)

if isempty(regexp(path,['gpml' pathsep]))
  cd ..; w = pwd; addpath([w, '/gpml']); cd gpml-demo    % add code dir to path
end

hold off
clear
clf
clc

disp('This demonstration illustrates the use of a Gaussian Process regression')
disp('for a multi-dimensional input vector, and illustrates the use of')
disp('automatic relevance determination (ARD).')
disp(' ');
disp('We initially consider a 2-d nonlinear robot arm mapping problem')
disp(' ')
disp('  f(x_1,x_2) = r_1 cos (x_1) + r_2 cos(x_1 + x_2)')
disp(' ')
disp('where x_1 is chosen randomly in [-1.932, -0.453], x_2 is chosen')
disp('randomly in [0.534, 3.142], and r_1 = 2.0, r_2 = 1.3. The target values')
disp('are obtained by adding Gaussian noise of variance 0.0025 to f(x_1,x_2).')
disp('Following Neal (1996) we add four further inputs, two of which')
disp('(x_3 and x_4) are copies of x_1 and x_2 corrupted by additive Gaussian')
disp('noise of standard deviation 0.02,  and two of which (x_5 and x_6) are')
disp('N(0,1) Gaussian noise variables. Our dataset has n=200 training points')
disp('and nstar=200 test points.')
disp(' ');
disp('Press any key to continue')
pause;

disp(' ')
disp('The training and test data is contained in the file data_6darm.mat')
disp('The raw training data is in the input matrix X (200 by 6) and the')
disp('target vector y (200 by 1). First, load the data')
disp(' ')
disp('  load data_6darm;')
load data_6darm;                                  % load training and test data

disp('  ')
disp('We first check the scaling of the input and target variables:')
disp(' ')
disp('  mean(X), std(X), mean(y), std(y)')
mean(X), std(X), mean(y), std(y)
disp(' ')
disp('We might be concerned if the standard deviation is very different for')
disp('different input dimensions; however, that is not the case here so we do')
disp('not carry out rescaling for X. However, y has a non-zero mean which is')
disp('not appropriate if we assume a zero-mean GP. We could add a constant')
disp('onto the SE covariance function corresponding to a prior on constant')
disp('offsets, but here instead we centre y by setting:')
disp(' ')
disp('  offset = mean(y);')
offset = mean(y);
disp('  y = y - offset;        % centre targets around 0')
y = y - offset;

% hyperparameters are stored as
% logtheta = [ log(ell_1)
%              log(ell_2) 
%               ...
%              log(ell_D)
%              log(sigma_f)
%              log(sigma_n) ]
%

disp(' ')
disp('Press any key to continue')
pause;

disp(' ')
disp('We use Gaussian process regression with a squared exponential')
disp('covariance function, and allow a separate lengthscale for each input')
disp('dimension, as in eqs. 5.1 and 5.2 of Rasmussen and Williams (2006).')
disp('These lengthscales (and the other hyperparameters sigma_f and sigma_n)')
disp('are adapted by maximizing the marginal likelihood  (eq. 5.8) w.r.t. the')
disp('hyperparameters. The covariance function is specified by')
disp(' ');
disp('  covfunc = {''covSum'', {''covSEard'',''covNoise''}};')
covfunc = {'covSum', {'covSEard','covNoise'}};
disp(' ');

disp('We now wish to train the GP by optimizing the hyperparameters. The')
disp('hyperparameters are stored as logtheta = [log(ell_1); log(ell_2); ...')
disp('log(ell_6); log(sigma_f), log(sigma_n)] (as D = 6), and are initialized')
disp('to')
disp(' ')
disp('  logtheta0 = [0; 0; 0; 0; 0; 0; 0; log(sqrt(0.1))]')
logtheta0 = [0; 0; 0; 0; 0; 0; 0; log(sqrt(0.1))];
disp(' ');
disp('The last values means that the initial noise variance is set to 0.1.')
disp(' ')
disp('Press any key to optimize the marginal likelihood.')
pause;

disp(' ')
disp('  [logtheta, fvals, iter] = minimize(logtheta0, ''gpr'', -100, covfunc, X, y);')
[logtheta, fvals, iter] = minimize(logtheta0, 'gpr', -100, covfunc, X, y);

disp(' ')
disp('We now plot the negative marginal likelihood as a function of the')
disp('number of line-searches of the optimization routine.')
disp(' ');
disp('Press any key to make the plot.')
pause;

plot(fvals)
hold on
plot(fvals,'bo')
ylabel('negative marginal likelihood')
xlabel('number of line-searches')
hold off

disp(' ')
disp('We now study the learned hyperparameters:')
disp(' ')
disp('Press any key to continue')
pause;

disp(' ')
fprintf(1, 'ell_1 \t\t%12.6f\n',exp(logtheta(1)));
fprintf(1, 'ell_2 \t\t%12.6f\n',exp(logtheta(2)));
fprintf(1, 'ell_3 \t\t%12.6f\n',exp(logtheta(3)));
fprintf(1, 'ell_4 \t\t%12.6f\n',exp(logtheta(4)));
fprintf(1, 'ell_5 \t\t%12.6f\n',exp(logtheta(5)));
fprintf(1, 'ell_6 \t\t%12.6f\n',exp(logtheta(6)))
fprintf(1, 'sigma_f \t%12.6f\n',exp(logtheta(7)));
fprintf(1, 'sigma_n \t%12.6f\n',exp(logtheta(8)));
disp(' ')
disp('The input variables x_1 to x_6 have similar scaling:')
disp(' ')
disp('std(X) =')
disp(std(X))
disp(' ')
disp('Thus it makes sense to compare their lengthscales. (If the scales were')
disp('very different then a standard procedure would be to rescale each input')
disp('variable to have zero mean and unit variance.) Notice that the')
disp('length-scales ell_1 and ell_2 are short indicating that inputs x_1 and')
disp('x_2 are relevant to the task. The noisy inputs x_3 and x_4 have longer')
disp('lengthscales, indicating they are less relevant, and the pure noise')
disp('inputs x_5 and x_6 have very long lengthscales, so they are effectively')
disp('irrelevant to the problem, as indeed we would hope. The process std')
disp('deviation sigma_f is similar in magnitude to the standard deviation of')
disp('the data std(y) = 1.2186. The learned noise standard deviation sigma_n')
disp('is very close the generative noise level sqrt(0.0025)=0.05.')
disp(' ')
disp('We now make predictions on the test points and assess the accuracy of')
disp('these predictions')
disp(' ')
disp('Press any key to continue')
pause;

% now make predictions

disp(' ')
disp('  [fstar S2] = gpr(logtheta, covfunc, X, y, Xstar);')
[fstar S2] = gpr(logtheta, covfunc, X, y, Xstar);

disp('  fstar = fstar + offset; % add back offset to get true prediction')
fstar = fstar + offset;

disp('  res = fstar-ystar;  % residuals')
res = fstar-ystar;  % residuals
disp('  mse = mean(res.^2);')
mse = mean(res.^2);
disp('  pll = -0.5*mean(log(2*pi*S2)+res.^2./S2);')
pll = -0.5*mean(log(2*pi*S2)+res.^2./S2);

disp(' ')
fprintf(1,'The mean squared error is %10.6f\n', mse);
fprintf(1,'and the mean predictive log likelihood is %6.4f.\n', pll);
disp(' ')
disp('Note that the mse is 0.002489 which is almost equal to the value 0.0025')
disp('as would be obtained from the perfect predictor, due to the added noise')
disp('with variance 0.0025.')
disp(' ')
disp('We also plot the residuals and the predictive variance for each')
disp('test case. Note that the order along the x-axis is arbitrary.')

subplot(2,1,1), plot(res,'.'), ylabel('residuals'), xlabel('test case')
subplot(2,1,2), plot(sqrt(S2),'.'),
ylabel('predictive std deviation'), xlabel('test case')

disp(' ')
disp('Press any key to end.')
pause

