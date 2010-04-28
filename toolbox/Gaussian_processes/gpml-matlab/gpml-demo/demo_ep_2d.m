% demonstrate the Expectation Propagation approximation on a 2-d
% classification task. 2006-03-29.

if isempty(regexp(path,['gpml' pathsep]))
  cd ..; w = pwd; addpath([w, '/gpml']); cd gpml-demo    % add code dir to path
end

clear
clf

disp('For demonstration purposes, we generate a simple data set where the')
disp('input of the data points from each of the two classes are generated')
disp('by sampling independently from a Gaussian distribution')
disp(' ')

disp('  n1=80; n2=40;                 % number of data points from each class')
n1=80; n2=40;
disp('  S1 = eye(2); S2 = [1 0.95; 0.95 1];     % the two covariance matrices')
S1 = eye(2); S2 = [1 0.95; 0.95 1];
disp('  m1 = [0.75; 0]; m2 = [-0.75; 0];                      % the two means')
m1 = [0.75; 0]; m2 = [-0.75; 0];                            
disp(' ')

disp('  randn(''seed'',17)')
randn('seed',17);
disp('  x1 = chol(S1)''*randn(2,n1)+repmat(m1,1,n1); % samples from one class')
x1 = chol(S1)'*randn(2,n1)+repmat(m1,1,n1);
disp('  x2 = chol(S2)''*randn(2,n2)+repmat(m2,1,n2);     % and from the other')
x2 = chol(S2)'*randn(2,n2)+repmat(m2,1,n2);
disp(' ')
disp('  x = [x1 x2]'';                             % these are the inputs and')
x = [x1 x2]';
disp('  y = [repmat(-1,1,n1) repmat(1,1,n2)]'';   % outputs for training data')
y = [repmat(-1,1,n1) repmat(1,1,n2)]';
disp(' ')
disp('Press any key to continue.')
pause

disp(' ')
disp('We now show the data, together with the Bayes Decision Probabilities')
disp('which are computed based on the generating distribution as follows:')
disp(' ')

disp('  [t1 t2] = meshgrid(-4:0.1:4,-4:0.1:4);')
[t1 t2] = meshgrid(-4:0.1:4,-4:0.1:4);
disp('  t = [t1(:) t2(:)];                        % these are the test inputs')
t = [t1(:) t2(:)];
disp(' ')
disp('  tt = sum((t-repmat(m1'',length(t),1))*inv(S1).*(t-repmat(m1'',length(t),1)),2);')
tt = sum((t-repmat(m1',length(t),1))*inv(S1).*(t-repmat(m1',length(t),1)),2);
disp('  z1 = n1*exp(-tt/2)/sqrt(det(S1));')
z1 = n1*exp(-tt/2)/sqrt(det(S1));
disp('  tt = sum((t-repmat(m2'',length(t),1))*inv(S2).*(t-repmat(m2'',length(t),1)),2);')
tt = sum((t-repmat(m2',length(t),1))*inv(S2).*(t-repmat(m2',length(t),1)),2);
disp('  z2 = n2*exp(-tt/2)/sqrt(det(S2));')
z2 = n2*exp(-tt/2)/sqrt(det(S2));
disp(' ')
disp('  contour(t1,t2,reshape(z2./(z1+z2),size(t1)),[0.1:0.1:0.9]);')
contour(t1,t2,reshape(z2./(z1+z2),size(t1)),[0.1:0.1:0.9]);
disp('  hold on')
hold on
disp('  plot(x1(1,:),x1(2,:),''b+'')')
plot(x1(1,:),x1(2,:),'b+')
disp('  plot(x2(1,:),x2(2,:),''r+'')')
plot(x2(1,:),x2(2,:),'r+')
disp(' ')
disp('Note that the ideal predictive probabilities depend only on the')
disp('density of the two classes, and not on the absolute density.')
disp(' ')
disp('Press any key to continue.')
pause

disp(' ')
disp('Now, we will fit a probabilistic Gaussian process classifier to this')
disp('data, using an implementation of Expectation Propagation. We must')
disp('specify a covariance function. First, we will try the squared')
disp('exponential covariance function ''covSEiso''. We must specify the')
disp('parameters of the covariance function (hyperparameters). For the')
disp('isotropic squared exponential covariance function there are two')
disp('hyperparameters, the lengthscale (kernel width) and the magnitude. We')
disp('need to specify values for these hyperparameters (see below for how to')
disp('learn them). Initially, we will simply set the log of these')
disp('hyperparameters to zero, and see what happens.')
disp(' ')

disp('  loghyper = [0; 0];')
loghyper = [0; 0];
disp('  p2 = binaryEPGP(loghyper, ''covSEiso'', x, y, t);')
p2 = binaryEPGP(loghyper, 'covSEiso', x, y, t);
disp('  clf')
clf
disp('  contour(t1,t2,reshape(p2,size(t1)),[0.1:0.1:0.9]);')
contour(t1,t2,reshape(p2,size(t1)),[0.1:0.1:0.9]);
disp('  hold on')
hold on
disp('  plot(x1(1,:),x1(2,:),''b+'')')
plot(x1(1,:),x1(2,:),'b+')
disp('  plot(x2(1,:),x2(2,:),''r+'')')
plot(x2(1,:),x2(2,:),'r+')
disp(' ')
disp('showing the predictive distribution. Although the predictive contours')
disp('in this plot look quite different from the Bayes Decision Probabilities')
disp('plotted previously, note that the predictive probabilities in regions')
disp('of high data density are not terribly different from those of the')
disp('generating process.')
disp(' ')
disp('Press any key to continue.')
pause

disp(' ')
disp('Recall, that this plot was made using hyperparameter which we')
disp('essentially pulled out of thin air. Now, we find the values of the')
disp('hyperparameters which maximize the marginal likelihood (or strictly,')
disp('the EP approximation of the marginal likelihood):')
disp(' ')
disp('  newloghyper = minimize(loghyper, ''binaryEPGP'', -20, ''covSEiso'', x, y)')
newloghyper = minimize(loghyper, 'binaryEPGP', -20, 'covSEiso', x, y)
disp('  p3 = binaryEPGP(newloghyper, ''covSEiso'', x, y, t);')
p3 = binaryEPGP(newloghyper, 'covSEiso', x, y, t);
disp(' ')
disp('where the argument -20 tells minimize to evaluate the function at most')
disp('20 times. The new hyperparameters have a fairly similar length scale,')
disp('but a much larger magnitude for the latent function. This leads to more')
disp('extreme predictive probabilities:')
disp(' ')
disp('  clf')
clf
disp('  contour(t1,t2,reshape(p3,size(t1)),[0.1:0.1:0.9]);')
contour(t1,t2,reshape(p3,size(t1)),[0.1:0.1:0.9]);
disp('  hold on')
hold on
disp('  plot(x1(1,:),x1(2,:),''b+'')')
plot(x1(1,:),x1(2,:),'b+')
disp('  plot(x2(1,:),x2(2,:),''r+'')')
plot(x2(1,:),x2(2,:),'r+')
disp(' ')
disp('Note, that this plot still shows that the predictive probabilities')
disp('revert to one half, when we move away from the data (in stark contrast')
disp('to the ''Bayes Decision Probabilities'' in this example). This may or')
disp('may not be seen as an appropriate behaviour, depending on our prior')
disp('expectations about the data. It is a direct consequence of the')
disp('behaviour of the squared exponential covariance function.')
disp(' ')
disp('Press any key to continue.')
pause

disp(' ')
disp('We can instead try a neural network covariance function')
disp('''covNNone.m'', which has the ability to saturate at specific latent')
disp('values as we move away from the origin:')
disp(' ')
disp('  newloghyper = minimize(loghyper, ''binaryEPGP'', -20, ''covNNone'', x, y);')
newloghyper = minimize(loghyper, 'binaryEPGP', -20, 'covNNone', x, y);
disp('  p4 = binaryEPGP(newloghyper, ''covNNone'', x, y, t);')
p4 = binaryEPGP(newloghyper, 'covNNone', x, y, t);
disp('  clf')
clf
disp('  contour(t1,t2,reshape(p4,size(t1)),[0.1:0.1:0.9]);')
contour(t1,t2,reshape(p4,size(t1)),[0.1:0.1:0.9]);
disp('  hold on')
hold on
disp('  plot(x1(1,:),x1(2,:),''b+'')')
plot(x1(1,:),x1(2,:),'b+')
disp('  plot(x2(1,:),x2(2,:),''r+'')')
plot(x2(1,:),x2(2,:),'r+')
disp(' ')
disp('which shows a somewhat less pronounced tendency for the predictive')
disp('probabilities to tend to one half as we move towards the boundaries of')
disp('the plot.')
disp(' ')
disp('Press any key to end.')
pause









