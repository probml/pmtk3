
% we first compile some code that will run on the mlcomp server
tmpFolder = 'C:\kmurphy\GoogleCode\mlcomp';
lambdaRange = []; % auto-generated
includeOffset = true;
nfolds = 5;
%fitArgs = {@penalizedL2,  lambdaRange, includeOffset, nfolds};
fitArgs = {[],  lambdaRange, includeOffset, nfolds};
mlcompCompiler('logregFitCV', 'logregPredict', tmpFolder, fitArgs);

% Now we run it
% Execute the following commands in octave to make sure it works
dataFile = 'C:\kmurphy\GoogleCode\pmtkData';
predFile = 'C:\kmurphy\GoogleCode\mlcomp\pred.txt';

%octave -qf run learn dataFile
%octave -qf run predict tmpFolder predFile
