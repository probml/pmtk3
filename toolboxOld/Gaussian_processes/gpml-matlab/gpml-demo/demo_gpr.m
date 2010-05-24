% demo script to illustrate use of gpr.m on 1-d data

if isempty(regexp(path,['gpml' pathsep]))
  cd ..; w = pwd; addpath([w, '/gpml']); cd gpml-demo    % add code dir to path
end

hold off
clear
clf
clc

disp('This demonstration illustrates the use of a Gaussian process model for')
disp('1-d regression problems. The demonstration data is consists of')
disp('20 points drawn from a Gaussian process:')
disp(' ')

n = 20;
rand('state',18);
randn('state',20);
covfunc = {'covSum', {'covSEiso','covNoise'}};
loghyper = [log(1.0); log(1.0); log(0.1)];
x = 15*(rand(n,1)-0.5);
y = chol(feval(covfunc{:}, loghyper, x))'*randn(n,1);        % Cholesky decomp.

disp('  plot(x, y, ''k+'')')
plot(x, y, 'k+', 'MarkerSize', 17)
disp('  hold on')
hold on

disp(' ')
disp('Press any key to continue.')
pause

disp(' ')
disp('We now compute the predictions using a Gaussian process at 201 test') 
disp('points evenly distributed in the interval [-7.5, 7.5]. In this simple')
disp('example, we use a covariance function whose functional form matches')
disp('the covariance function which was used to generate the data. In this')
disp('case, this was a sum of a squared exponential (SE) covariance term, and')
disp('independent noise. Thus, the test cases and covariance function are')
disp('specified as follows:')
disp(' ')
xstar = linspace(-7.5, 7.5, 201)';
disp('  xstar = linspace(-7.5, 7.5, 201)'';')
covfunc = {'covSum', {'covSEiso','covNoise'}};
disp('  covfunc = {''covSum'', {''covSEiso'',''covNoise''}};')
disp(' ')
disp('where the specification of covfunc says that the covariance should be a')
disp('sum of contributions from the two functions covSEiso and covNoise. The')
disp('help for covFunctions give more details about how to specify covariance')
disp('functions.')
disp(' ')
disp('Press any key to continue.')
pause

disp(' ')
disp('We have now specified the functional form of the covariance function')
disp('but we still need to specify values of the parameters of these')
disp('covariance functions. In our case we have 3 parameters (also sometimes')
disp('called hyperparameters). These are: a characteristic length-scale for')
disp('the squared exponential (SE) contribution, a signal magnitude for the')
disp('SE contribution, and the standard deviation of the noise. The logarithm')
disp('of these parameters are specified:')
disp(' ')
disp('  loghyper = [log(1.0); log(1.0); log(0.1)];')
loghyper = [log(1.0); log(1.0); log(0.1)];
disp(' ')
disp('to specify a unit length scale, unit magnitude and a noise variance of')
disp('0.01 (corresponding to a standard deviation of 0.1')
disp(' ')
disp('Press any key to continue.')

disp(' ')
disp('Now, we use the gpr program, to make predictions, and we plot these by')
disp('showing the mean prediction and two standard error (95% confidence),')
disp('noise free, pointwise errorbars:')
disp(' ')
disp('  [mu, S2] = gpr(loghyper, covfunc, x, y, xstar);')
[mu, S2] = gpr(loghyper, covfunc, x, y, xstar);
disp('  S2 = S2 - exp(2*loghyper(3));')
S2 = S2 - exp(2*loghyper(3));
disp('  errorbar(xstar, mu, 2*sqrt(S2), ''g'');')
errorbar(xstar, mu, 2*sqrt(S2), 'g');
plot(x, y, 'k+', 'MarkerSize', 17)       % refresh points covered by errorbars!
disp(' ')
disp('Note that since we are interested in the distribution of the function')
disp('values and not the noisy examples, we subtract the noise variance, which')
disp('is stored in hyperparameter number 3, from the predictive variance S2.')
disp(' ')
disp('Press any key to continue.')
pause

disp(' ')
disp('Alternatively, the error bar range can be displayed in gray-scale to')
disp('reproduce Figure 2.5(a):')

clf
f = [mu+2*sqrt(S2);flipdim(mu-2*sqrt(S2),1)];
fill([xstar; flipdim(xstar,1)], f, [7 7 7]/8, 'EdgeColor', [7 7 7]/8);
hold on
plot(xstar,mu,'k-','LineWidth',2);
plot(x, y, 'k+', 'MarkerSize', 17);

disp(' ')
disp('Press any key to continue.')
pause

disp(' ')
disp('We now investigate changing the hyperparameters to have the values:')
disp(' ')
disp('  loghyper = [log(0.3); log(1.08); log(5e-5)];')
loghyper = [log(0.3); log(1.08); log(5e-5)];
disp(' ')
disp('so as to reproduce Figure 2.5(b). The lengthscale is now shorter (0.3)')
disp('and the noise level is much reduced, so the predicted mean almost')
disp('interpolates the data points. Notice that the error bars grow rapidly')
disp('away from the data points due to the short lengthscale.')
disp(' ')

disp('  [mu, S2] = gpr(loghyper, covfunc, x, y, xstar);')
[mu S2] = gpr(loghyper, covfunc, x, y, xstar);
disp('  S2 = S2 - exp(2*loghyper(3));')
S2 = S2 - exp(2*loghyper(3));

clf
f = [mu+2*sqrt(S2);flipdim(mu-2*sqrt(S2),1)];
fill([xstar; flipdim(xstar,1)], f, [7 7 7]/8, 'EdgeColor', [7 7 7]/8);
hold on
plot(xstar,mu,'k-','LineWidth',2);
plot(x, y, 'k+', 'MarkerSize', 17);

disp(' ')
disp('Press any key to continue.')
pause

disp(' ')
disp('Alternatively we can change the hyperparameters to have the values:')
disp(' ')
disp('  loghyper = [log(3.0); log(1.16); log(0.89)]')
loghyper = [log(3.0); log(1.16); log(0.89)];  
disp(' ')
disp('so as to reproduce Figure 2.5(c). The lengthscale is now longer than')
disp('initially and the noise level is higher. Thus the predictive mean')
disp('function varies more slowly than before.')
disp(' ')
disp('  [mu S2] = gpr(loghyper, covfunc, x, y, xstar);')
[mu S2] = gpr(loghyper, covfunc, x, y, xstar);
disp('  S2 = S2 - exp(2*loghyper(3));')
S2 = S2 - exp(2*loghyper(3));

clf
f = [mu+2*sqrt(S2);flipdim(mu-2*sqrt(S2),1)];
fill([xstar; flipdim(xstar,1)], f, [7 7 7]/8, 'EdgeColor', [7 7 7]/8);
hold on
plot(xstar,mu,'k-','LineWidth',2);
plot(x, y, 'k+', 'MarkerSize', 17);

disp(' ')
disp('Press any key to continue.')
pause

disp(' ')
disp('We also illustrate learning the hyperparameters by maximizing the')
disp('marginal likelihood. The hyperparameters are initialized to:')
disp(' ')
disp('  loghyper = [-1; -1; -1]')
disp(' ')
disp('and we allow the minimize function to use 100 function evaluations')

disp(' ')
disp('Press any key to continue.')
pause

disp(' ')
disp('  loghyper = minimize(loghyper, ''gpr'', -100, covfunc, x, y);')
disp(' ')
loghyper = minimize(loghyper, 'gpr', -100, covfunc, x, y);
disp('  exp(loghyper) =')
disp(' ')
disp(exp(loghyper))
disp(' ')
disp('Note that the hyperparameters learned here are close, but not identical')
disp('to the parameters 1.0, 1.0, 0.1 used when generating the data.') 
disp('The discrepancy is partially due to the small training sample size,')
disp('and partially due to the fact that we only get information about the') 
disp('process in a very limited range of input values. Repeating the')
disp('experiment with more training points distributed over wider range leads')
disp('to more accurate estimates.')
disp(' ')
disp('Press any key to continue.')
pause

disp(' ')
disp('Finally, we compute and plot the predictions using the learned')
disp('hyperparameters:')
disp(' ')
disp('  [mu S2] = gpr(loghyper, covfunc, x, y, xstar);')
[mu S2] = gpr(loghyper, covfunc, x, y, xstar);
disp('  S2 = S2 - exp(2*loghyper(3));')
S2 = S2 - exp(2*loghyper(3));

clf
f = [mu+2*sqrt(S2);flipdim(mu-2*sqrt(S2),1)];
fill([xstar; flipdim(xstar,1)], f, [7 7 7]/8, 'EdgeColor', [7 7 7]/8);
hold on
plot(xstar,mu,'k-','LineWidth',2);
plot(x, y, 'k+', 'MarkerSize', 17);

disp(' ')
disp('showing a reasonable fit, with a relatively tight confidence region.')
disp(' ')
disp('Press any key to continue.')
pause

disp(' ')
disp('Note, that above we have use the same functional form for the')
disp('covariance function, as was used to generate the data. In practise')
disp('things are seldom so simple, and one may have to try different')
disp('covariance functions. Here, we try to explore how a Matern form, with')
disp('a shape parameter of 3/2 would do.')
disp(' ')
disp('  covfunc2 = {''covSum'',{''covMatern3iso'',''covNoise''}};')
covfunc2 = {'covSum',{'covMatern3iso','covNoise'}};
disp('  loghyper2 = minimize([-1; -1; -1], ''gpr'', -100, covfunc2, x, y);')
loghyper2 = minimize([-1; -1; -1], 'gpr', -100, covfunc2, x, y);
disp(' ')
disp('Press any key to continue.')
pause

disp(' ')
disp('Comparing the value of the marginal likelihoods for the two models')
disp(' ')
disp('  -gpr(loghyper, covfunc, x, y)')
-gpr(loghyper, covfunc, x, y)
disp('  -gpr(loghyper2, covfunc2, x, y)')
-gpr(loghyper2, covfunc2, x, y)
disp(' ')
disp('with values of -15.6 for SE and -18.0 for Matern3, shows that the SE')
disp('covariance function is about exp(18.0-15.6)=11 times more probable than')
disp('the Matern form for these data (in agreement with the data generating')
disp('process). The predictions from the worse Matern-based model')
disp(' ')
disp('  [mu S2] = gpr(loghyper2, covfunc2, x, y, xstar);')
[mu S2] = gpr(loghyper2, covfunc2, x, y, xstar);
disp('  S2 = S2 - exp(2*loghyper2(3));')
S2 = S2 - exp(2*loghyper2(3));

clf
f = [mu+2*sqrt(S2);flipdim(mu-2*sqrt(S2),1)];
fill([xstar; flipdim(xstar,1)], f, [7 7 7]/8, 'EdgeColor', [7 7 7]/8);
hold on
plot(xstar,mu,'k-','LineWidth',2);
plot(x, y, 'k+', 'MarkerSize', 17);

disp(' ')
disp('Notice how the uncertainty grows more rapidly in the vicinity of data-')
disp('points, reflecting the property that the sample paths for the Matern')
disp('class of functions with a shape parameter of 3/2 don''t have second')
disp('derivatives (and are thus much less smooth than the SE covariance')
disp('function).')
disp(' ')
disp('Press any key to end.')
pause