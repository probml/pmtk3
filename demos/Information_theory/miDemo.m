%% Demonstration of computing pairwise mutual information

load newsgroups % documents, wordlist, newsgroups
X = documents'; % 16,642 documents by 100 words  (sparse logical  matrix)

tic; [mi] = mutualInfoAllPairsDiscrete(X);toc
tic; [mi2] = mutualInfoAllPairsMixed(X); toc
%tic; [mi3] = mutualInfoAllPairsMixed(X, [], 'useSpeedup', false); toc

approxeq(mi, mi2)
approxeq(mi, mi3)