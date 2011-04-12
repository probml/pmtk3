% Demo of factor analysis applied to some synthetic 2d binary data

% This file is from pmtk3.googlecode.com


setSeed(0);
D = 16;
K = 3;
proto = rand(D,K) < 0.5;
M = 50;
source = [1*ones(1,M) 2*ones(1,M) 3*ones(1,M)];
N = numel(source);
dataClean = zeros(N, D);
for n=1:N
  src = source(n);
  dataClean(n, :) = proto(:, src)';
end
noiseLevel = 0.05;
flipMask = rand(N,D) < noiseLevel;
dataNoisy = dataClean;
dataNoisy(flipMask) = 1-dataClean(flipMask);
dataMissing = dataClean;
dataMissing(flipMask) = nan;

figure; imagesc(dataNoisy); colormap(gray);
title('noisy binary data')
printPmtkFigure('binaryPCAinput');

figure; imagesc(dataClean); colormap(gray); title('hidden truth')

% Fit model
[model, loglikHist] = binaryFAfit(dataNoisy, 2, 'maxIter', 10, 'verbose', true);
figure; plot(loglikHist); title('(lower bound on) loglik vs iter for EM')

% Latent 2d embedding
muPost = binaryFAinferLatent(model, dataNoisy);
figure;
symbols = {'ro', 'gs', 'k*'};
for k=1:K
  ndx = (source==k);
  plot(muPost(1,ndx), muPost(2,ndx), symbols{k});
  hold on
end
title('latent embedding')
printPmtkFigure('binaryPCAoutput')

% Denoising
[postPred] = binaryFApredictMissing(model, dataNoisy);
yhat = postPred > 0.5;
figure; imagesc(yhat); colormap(gray); title('prediciton given noisy')

% Imputation
[postPred] = binaryFApredictMissing(model, dataMissing);
yhat = postPred > 0.5;
figure; imagesc(yhat); colormap(gray); title('prediction given missing data')
