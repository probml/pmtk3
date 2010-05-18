%% Demonstration of computing pairwise mutual information

load newsgroups % documents, wordlist, newsgroups
X = documents'; % 16,642 documents by 100 words  (sparse logical  matrix)

tic; [mi, nmi] = mutualInfoAllPairsDiscrete(X);toc
tic; [mi2] = mutualInfoAllPairsMixed(X); toc

mi = setdiag(mi, 0);
assert(approxeq(mi, mi2))