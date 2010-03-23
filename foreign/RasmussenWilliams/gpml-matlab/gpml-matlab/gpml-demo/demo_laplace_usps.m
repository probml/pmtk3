% Demo script to illustrate use of binaryLaplaceGP.m on a binary digit
% classification task. 2006-03-29.

if isempty(regexp(path,['gpml' pathsep]))
  cd ..; w = pwd; addpath([w, '/gpml']); cd gpml-demo    % add code dir to path
end

hold off
clear
clf
clc

disp('This demonstration illustrates the use of Laplace''s approximation for')
disp('binary Gaussian process classification applied to a digit task.')
disp(' ')

if exist('loadBinaryUSPS') ~= 2
  disp('Error: can''t find the loadBinaryUSPS.m file. For this example, you')
  disp('need to download the usps_resampled archive. It is available at')
  disp('http://www.GaussianProcess.org/gpml/data')
  return
end  

disp('The data consists of 16 by 16 grey scale images of handwritten digits')
disp('derived from the USPS data set. We will consider the binary')
disp('classification task of separating 3''s from 5''s. The training set')
disp('contains 767 cases and the test set 773 cases. Here is an example')
disp('image of a digit 3.');
disp(' ');

disp('  [x y xx yy] = loadBinaryUSPS(3, 5);')
[x y xx yy] = loadBinaryUSPS(3, 5);
disp('  imagesc(reshape(x(3,:),16,16)''), colormap(''gray'')')
imagesc(reshape(x(3,:),16,16)'), colormap('gray')

disp(' ')
disp('Press any key to continue.')
disp(' ')
pause

disp('We must specify a covariance function and a likelihood function. For')
disp('the demonstration we use the squared exponential (SE) covariance')
disp('function but many other covariance functions are supported as well.')
disp('The SE covariance function has two parameters; a log length-scale')
disp('parameter and a log magnitude parameter. As an initial guess for the')
disp('parameters, we set the log length-scale to the log of the average')
disp('pairwise distance between training points, roughly log(22)=3 and the')
disp('magnitude is set to unity, ie it''s log to 0. Other initial choices')
disp('could be reasonable too. We chose the cumulative Gaussian as')
disp('likelihood function.')
disp(' ');
disp('We then call the binaryLaplaceGP function, which constructs the Laplace')
disp('approximation of the posterior over functions based on the training set')
disp('and produces probabilistic predictions for the test cases. This may')
disp('take a minute or so...')
disp(' ')


disp('  loghyper = [3.0; 0.0];   % set the log hyperparameters')
loghyper = [3.0; 0.0];   % set the log hyperparameters
disp('  p = binaryLaplaceGP(loghyper, ''covSEiso'', ''cumGauss'', x, y, xx);')
p = binaryLaplaceGP(loghyper, 'covSEiso', 'cumGauss', x, y, xx);
disp(' ')

disp('  plot(p,''.'')');
plot(p,'.')
disp('  hold on');
hold on
disp('  plot([1 length(p)],[0.5 0.5],''r'')');
plot([1 length(p)],[0.5 0.5],'r')
xlabel('test case number')
ylabel('predictive probability')
axis([0 length(p) 0 1])

disp(' ')
disp('Press any key to continue.')
disp(' ')
pause

disp('Keep in mind that the test cases are ordered according to their')
disp('target class. Notice that there are misclassifications, but there are')
disp('no very confident misclassifications. The number of test set errors')
disp('(out of 773 test cases) when thresholding the predictive probability at')
disp('0.5 and the average amount of information about the test set labels in')
disp('excess of a 50/50 model in bits are given by:')
disp(' ')

disp('  sum((p>0.5)~=(yy>0))')
sum((p>0.5)~=(yy>0))
disp('  mean((yy==1).*log2(p)+(yy==-1).*log2(1-p))+1')
mean((yy==1).*log2(p)+(yy==-1).*log2(1-p))+1

disp(' ')
disp('Press any key to continue.')
disp(' ')
pause

disp('These results were obtained by simply guessing some values for the')
disp('hyperparameters. We can instead optimize the marginal likelihood on')
disp('the training set w.r.t. the hyperparameters. The current values');
disp('of the log hyperparameters (2 numbers), and the initial value')
disp('of the negative log marginal likelihood are:')
disp(' ')

disp('  [loghyper'' binaryLaplaceGP(loghyper, ''covSEiso'', ''cumGauss'', x, y)]')
[loghyper' binaryLaplaceGP(loghyper, 'covSEiso', 'cumGauss', x, y)]

disp(' ')
disp('Press any key to continue.')
disp(' ')
pause

disp('Now, we minimize the negative log marginal likelihood w.r.t. the')
disp('hyperparameters. The third argument -20 tells minimize to evaluate the')
disp('function a maximum of 20 times... this may take a few minutes or so...')
disp('depending on whether you compiled the mex files...')
disp(' ')

disp('  [newloghyper logmarglik] = minimize(loghyper, ''binaryLaplaceGP'', -20, ''covSEiso'', ''cumGauss'', x, y);')
[newloghyper logmarglik] = minimize(loghyper, 'binaryLaplaceGP', -20, 'covSEiso', 'cumGauss', x, y);
disp('  [newloghyper'' logmarglik(end)]')
[newloghyper' logmarglik(end)]

disp(' ')
disp('This shows that the log marginal likelihood was increased from -222 to')
disp('-99 by optimizing the hyperparameters. This means that the marginal')
disp('likelihood has increased by a factor of exp(222-99) = 3e+53.')

disp(' ')
disp('Press any key to continue.')
disp(' ')
pause

disp('Finally, we can make test set predictions with the new hyperparameters:')
disp(' ')

disp('  pp = binaryLaplaceGP(newloghyper, ''covSEiso'', ''cumGauss'', x, y, xx);')
pp = binaryLaplaceGP(newloghyper, 'covSEiso', 'cumGauss', x, y, xx);
disp('  plot(pp,''g.'')');
plot(pp,'g.')

disp(' ')
disp('We note that the new predictions (in green) take much more extreme')
disp('values values than the old ones (in blue).')

disp(' ')
disp('Press any key to continue.')
disp(' ')
pause

disp('The number of test set errors (out of 773 test cases) when')
disp('thresholding the predictive probability at 0.5 and the average amount')
disp('of information about the test set labels in excess of a 50/50 model')
disp('in bits are given by:')
disp(' ')

disp('  sum((pp>0.5)~=(yy>0))')
sum((pp>0.5)~=(yy>0))
disp('  mean((yy==1).*log2(pp)+(yy==-1).*log2(1-pp))+1')
mean((yy==1).*log2(pp)+(yy==-1).*log2(1-pp))+1

disp(' ')
disp('showing that misclassification rate has dropped and the information')
disp('about the test target labels has increased compared to using the old')
disp('initially guessed values for the hyperparaneters.')
disp(' ')
disp('Press any key to exit.')
disp(' ')
pause
