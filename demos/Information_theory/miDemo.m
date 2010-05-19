%% Demonstration of computing pairwise mutual information

load newsgroups 
tic; [mi] = mutualInfoAllPairsDiscrete(X);toc
tic; [mi2] = mutualInfoAllPairsMixed(X); toc
tic; [mi3] = mutualInfoAllPairsMixed(X, [], 'useSpeedup', false); toc

approxeq(mi, mi2)
approxeq(mi, mi3)