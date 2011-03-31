% Run BXPCA

clear; clc;

numFactors = 3; % Latent dimension K
simParams.stepSize = 4e-3; % need to choose these.
simParams.numLeaps = 10;
simParams.numIter = 1000;

dataname = sprintf('syntheticData%d',1);
load(dataname);
[numObs numFeatures] = size(trainData);
C = 0.5;
alpha = 2.1;  beta = 3.1;
a = repmat(2, 1, numFeatures);
b = repmat(5, 1, numFeatures);
lambda = [a' b'];
m = zeros(numFactors,1); % dim Kx1
S = C*eye(numFactors); debug = 1;
[result stats] = HMC_missData(simParams, numFactors, lambda, alpha, beta, m, S, trainData, debug);

% quick check
pairwise = zeros(numObs,numFeatures );
ppp = zeros(numObs,numFeatures);
endPos = size(result,1);
startPos = round(endPos/2);
len = endPos - startPos + 1;
for k = startPos:endPos
    [V Theta Sigma mu] = extractParams(result(k,3:end),numFeatures, numObs, numFactors);
    pairwise = V*Theta;
    ppp = ppp + pairwise;
end;
pStar = ppp ./len; 
recon = 1 ./(1 + exp(-pStar));
errorTrain = X(trainData ~= -1) - recon(trainData ~= -1);
errorTest = X(testData ~= -1) - recon(testData ~= -1);
errorAll = X - recon;
RMSEtrain = sqrt(sum(sum (errorTrain.^2))) / sqrt(numel(errorTrain));
RMSEtest = sqrt(sum(sum (errorTest.^2))) / sqrt(numel(errorTest));
RMSEall = sqrt(sum(sum (errorAll.^2))) / sqrt(numel(errorAll));
