% Let us run logregSATdemo on the mlcomp syste,

%% we first compile some code that will run on the mlcomp server
tmpFolder = 'C:\kmurphy\GoogleCode\mlcomp';
lambdaRange = []; % auto-generated
includeOffset = true;
nfolds = 5;
%fitArgs = {@penalizedL2,  lambdaRange, includeOffset, nfolds};
fitArgs = {[],  lambdaRange, includeOffset, nfolds};
mlcompCompiler('logregFit', 'logregPredict', tmpFolder, fitArgs);

%% Now convert data
dataFile = fullfile(tmpFolder, 'satData-mlcomp.txt');
stat = load('satData.txt'); 
y = stat(:,1);
X = stat(:,4);
mlcompWriteData(X, y, dataFile)
 
% Now we run it
% Execute the following commands in octave to make sure it works
predFile = fullfile(tmpFolder, 'satData-logreg-mlcomp-pred.txt')
%octave -qf run learn dataFile
%octave -qf run predict tmpFolder predFile
