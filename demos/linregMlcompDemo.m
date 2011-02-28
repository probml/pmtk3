%% Run linear regression on the mlcomp system
% See also mlcompLocalDemo
%% we first compile some code that will run on the mlcomp server

% This file is from pmtk3.googlecode.com

%PMTKinprogress

if 0
tmpFolder = 'C:\kmurphy\GoogleCode\mlcomp';
else
    tmpFolder = tempdir();
end
lambdaRange = []; % auto-generated
includeOffset = true;
nfolds = 5;
mlcompCompiler('linregFit', 'linregPredict', tmpFolder);

%% Now convert data
dataFile = fullfile(tmpFolder, 'prostate-mlcomp.txt');
loadData('prostate');
mlcompWriteData(X, y, dataFile)
 
% Now we run it
% Execute the following commands in octave to make sure it works
predFile = fullfile(tmpFolder, 'satData-logreg-mlcomp-pred.txt')
%octave -qf run learn dataFile
%octave -qf run predict tmpFolder predFile


