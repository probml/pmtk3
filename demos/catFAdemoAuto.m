%function catFAdemoAuto()
% Factor analysis with categorical and continuous data
% We reproduce the demo from
% http://www.cs.ubc.ca/~emtiyaz/software/mixedDataFA.html


clear all;
clf;
%[data, nClass] = getData('auto',[]);
%[data, nClass] = getAutoData;
load autoData;
Dz = 2;
setSeed(3);

% First just use cts data
dataC = data;
dataC.discrete = [];
modelC = catFAfit(dataC, Dz);

meanC = catFAinferLatent(modelC, dataC);

catFAdemoAutoPlot(data, meanC, 'cts', nClass);

break

% Now use cts and discrete data
setSeed(3);
modelCD = catFAfit(data, Dz);
meanCD = catFAinferLatent(modelCD, data);

catFAdemoAutoPlot(data, meanCD, 'cts+discrete', nClass)
