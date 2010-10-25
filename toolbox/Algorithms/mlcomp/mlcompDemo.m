%% Demo of mlcomp

% This file is from pmtk3.googlecode.com


addtosystempath('C:\Octave\3.2.3_gcc-4.4.0\bin');
%localdir = tempdir(); %'C:\users\matt\desktop'; 
localdir = fullfile(pmtk3Root(), 'data');


%% regression
% This is pure matlab code and works fine
if 1
  setSeed(0);
  N = 10; D = 3;
  X = randn(N,D);
  w = randn(D,1);
  y = X*w + randn(N,1);
  
  mlcompWriteData(X, y, fullfile(localdir, 'data'));
  % linregFit supports L1 as well as L2,
  % and the L1 code is complex and does not work on octave.
  % So we call a simple matlab function
  % that just does L2.
  % mlcompCompiler('linregFit', 'linregPredict', localdir);
  lambda = 0.1;
  mlcompCompiler('linregFitSimple', 'linregPredict', localdir, {lambda});
  cd(localdir);
  system(sprintf('octave -qf run learn data'));
  system(sprintf('octave -qf run predict data yhat'));
  
  yhat1 = str2double(getText('yhat'));
  mse1 = mean( (yhat1-y) .^ 2)
  
  % Compare against matlab version
  model = linregFitSimple(X, y, lambda);
  yhat2  = linregPredict(model, X);
  mse2 = mean( (yhat2-y) .^ 2)
end

%% Logistic regression
% This uses minfunc, which does not run on octave
% because it has nested functions.
if 0
  stat = load('satData.txt');
  X = stat(:, 4);
  y = stat(:, 1) + 1;
  
  mlcompWriteData(X, y, fullfile(localdir, 'data'));
  mlcompCompiler('logregFit', 'logregPredict', localdir);
  cd(localdir);
  system(sprintf('octave -qf run learn data'));
  system(sprintf('octave -qf run predict data yhat'));
  yhat1 = str2double(getText('yhat'))
  nerrs1 = sum(yhat1 ~= y)
  
  % Compare against matlab version
  model = logregFit(X, y);
  yhat2  = logregPredict(model, X);
  nerrs2 = sum(yhat2 ~= y)
end

