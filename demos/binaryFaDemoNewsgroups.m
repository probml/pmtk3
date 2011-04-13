% Demo of factor analysis applied to binary newsgroups bag of words
% We compute 2d embedding

% This file is from pmtk3.googlecode.com

requireStatsToolbox; % cmdscale

setSeed(0);
loadData('20news_w100');
% documents, wordlist, newsgroups, groupnames
labels = double(full(documents))'; % 16,642 documents by 100 words  (sparse logical  matrix)
[N,D] = size(labels);
perm = randperm(N);
data = labels(1:perm(500), :);
[N,D] = size(data);
maxIter = 6; % EM convergers really fast

%{
% Latent 2d embedding - very poor
% We don't request loglik hist for speed
[model2d] = binaryFAfit(data, 2, 'maxIter',maxIter, 'verbose', true);

% See where each word maps to
dummy = eye(D);
muPost2d = binaryFAinferLatent(model2d, dummy);
figure; hold on
% We need to plot points before text
for d=1:D
  plot(muPost2d(1,d), muPost2d(2,d), '.');
end
ndx = 1:1:D;
for d=ndx(:)'
  text(muPost2d(1,d), muPost2d(2,d), wordlist{d});
end
title(sprintf('latent 2d embedding of %d newsgroups words', D))
%}


% Latent higher dim embedding
nlatent = 10;
[modelBig, loglikHist] = binaryFAfit(data, nlatent, 'maxIter', maxIter, ...
  'verbose', true, 'computeLoglik', false);

% See where each word maps to
dummy = eye(D);
muPostBig = binaryFAinferLatent(modelBig, dummy);
% muPost is L*N, reduce to N*2 for vis purposes using MDS
dst = pdist(muPostBig','Euclidean');
[mdsCoords,eigvals] = cmdscale(dst);
eigVals(1:5)

figure; hold on
% We need to plot points before text
for d=1:D
  plot(mdsCoords(d,1), mdsCoords(d,2), '.');
end
ndx = 1:1:D;
for d=ndx(:)'
  text(mdsCoords(d,1), mdsCoords(d,2), wordlist{d});
end
title(sprintf('latent %d-d embedding of %d newsgroups words', nlatent, D))
