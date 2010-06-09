%% Computing pairwise mutual information, timing comparison

%PMTKneedsStatsToolbox hist3
requireStatsToolbox
loadData('newsgroups');
tic; [mi] = mutualInfoAllPairsDiscrete(X);toc
tic; [mi2] = mutualInfoAllPairsMixed(X); toc
tic; [mi3] = mutualInfoAllPairsMixed(X, [], 'useSpeedup', false); toc

approxeq(mi, mi2)
approxeq(mi, mi3)