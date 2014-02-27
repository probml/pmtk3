#!/usr/bin/env python

from sklearn.datasets import load_iris
from matplotlib import pylab as pl
from itertools import permutations


data = load_iris()
features = data['data']
feature_names = data['feature_names']
target = data['target']

feature_combinations = list(permutations(range(4), 2))
for i in range(16):
    if i % 5 == 0:
        features_sel = features[:, int(i/5)]
        pl.subplot(4, 4, i+1)
        pl.hist(features_sel, color='w')
        pl.xlabel(feature_names[int(i/5)], fontsize=10)
        pl.ylabel(feature_names[int(i/5)], fontsize=10)
    else:
        pl.subplot(4, 4, i+1)
        for t, m, c in zip(range(3), 'D*o', 'bgr'):
            feature_chosen = feature_combinations[i-1-(i//5)]
            pl.scatter(features[target == t, feature_chosen[0]],
                       features[target == t, feature_chosen[1]],
                       marker=m, color=c)
        pl.xlabel(feature_names[feature_chosen[0]], fontsize=10)
        pl.ylabel(feature_names[feature_chosen[1]], fontsize=10)
    pl.xticks(())
    pl.yticks(())

pl.savefig('fisheririsDemo.png')
pl.show()
