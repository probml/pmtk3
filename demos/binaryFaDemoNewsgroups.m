% Demo of factor analysis applied to binary newsgroups bag of words
% We compute 2d embedding

%PMTKreallySlow

% This file is from pmtk3.googlecode.com

requireStatsToolbox; % cmdscale

setSeed(0);
loadData('20news_w100');
% documents, wordlist, newsgroups, groupnames
wordocc = double(full(documents))'; % 16,642 documents by 100 words  (sparse logical  matrix)
[N,D] = size(wordocc);
perm = randperm(N);
ndx = perm(1:5000);
data = wordocc(ndx, :);
[N,D] = size(data);
classLabels = newsgroups(ndx);

%{
% Latent 2d embedding - very poor
% We don't request loglik hist for speed
[model2d] = binaryFAfit(data, 2, 'maxIter', 6, 'verbose', true);

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

methods = [];
m = 0;

Ks = [10, 50];
for kk=1:numel(Ks)
  K = Ks(kk);
  m = m + 1;
  methods(m).modelname = 'JJ';
  methods(m).fitFn = @(data) binaryFAfit(data, K, 'maxIter', 6, ...
    'verbose', true, 'computeLoglik', false);
  methods(m).infFn = @(model, labels) binaryFAinferLatent(model, labels);
  methods(m).nlatent = K;
end


%Ks = [];
for kk=1:numel(Ks)
  K = Ks(kk);
  m = m + 1;
  methods(m).modelname = 'Bohning';
  methods(m).fitFn = @(data) catFAfit(data, [], K, 'maxIter', 10, ...
    'verbose', true, 'nClass', 2*ones(1,D));
  methods(m).infFn = @(model, labels) catFAinferLatent(model, labels, []);
  methods(m).nlatent = K;
end


Nmethods = numel(methods);
for m=1:Nmethods
  fitFn = methods(m).fitFn;
  infFn = methods(m).infFn;
  methodname = methods(m).modelname;
  
  tic
  model = fitFn(data);
  timMethod(m) = toc
  
  % Compute latent embedding of each possible delta function
  dummy = eye(D);
  muPost = infFn(model, dummy);
  
  % muPost is L*N, reduce to N*2 for vis purposes using MDS
  dst = pdist(muPost','Euclidean');
  [mdsCoords,eigvals] = cmdscale(dst);
  eigvals(1:5)
  
  figure; hold on
  % We need to plot points before text
  for d=1:D
    plot(mdsCoords(d,1), mdsCoords(d,2), '.');
  end
  ndx = 1:1:D;
  for d=ndx(:)'
    %text(mdsCoords(d,1), mdsCoords(d,2), wordlist{d}, 'fontsize', 10);
  end
  nlatent = methods(m).nlatent;
  title(sprintf('L=%d, N=%d, method = %s', nlatent, N, methodname))
  fname = sprintf('binaryFAnewsgroups-%s-L%d-N%d', methodname, nlatent, N);
  printPmtkFigure(fname);
end