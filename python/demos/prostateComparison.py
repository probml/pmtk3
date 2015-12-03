#!/usr/bin/env python3

from itertools import chain, combinations
from scipy.stats import linregress
from sklearn.cross_validation import cross_val_score
from sklearn.linear_model import LassoCV, LinearRegression, RidgeCV
from sklearn.metrics import mean_squared_error
from sklearn.preprocessing import scale
from utils import load_mat

import csv
import numpy as np


def _format(s):
  return '{0:.3f}'.format(s)

# Normalize each column to have a mean of 0, std dev of 1. Use ddof=1
# to get consistent results with R.
def _scale(X):
  for column in X.T:
    mu = np.mean(column)
    sigma = np.std(column, ddof=1)
    column -= mu
    column /= sigma
  return X

# Returns the subset of features that give the smallest Least Squares error.
def _best_subset_cv(model, X, y, cv=3):
  n_features = X.shape[1]
  subsets = chain.from_iterable(combinations(range(n_features), k+1) for k in range(n_features + 1))
  best_score = -np.inf
  best_subset = None
  for subset in subsets:
      score = cross_val_score(model, X[:, subset], y, cv=cv).mean()
      if score > best_score:
          best_score, best_subset = score, subset

  return best_subset

X = load_mat('prostate')

# Hack to use the correct dataset.
X['Xtest'][8][1] = 3.804438
# Rescale all data at once.
Xscaled = _scale(np.append(X['Xtrain'], X['Xtest'], axis=0))
Xtrain = Xscaled[0:67,:]
Xtest = Xscaled[67:,:]
ytrain = X['ytrain']
ytest = X['ytest']

methods=[LassoCV(), RidgeCV(cv=3), LinearRegression()]
method_names = ["Lasso", "Ridge", "Least Squares"]
intercepts=["Intercept"]
coefficients=[["lcalvol"], ["lweight"], ["age"], ["lbph"], ["svi"], ["lcp"], ["gleason"], ["pgg45"]]
MSEs=["Test Error"]
SEs=["Standard Error"]

for i,method in enumerate(methods):
  clf = method
  model = clf.fit(Xtrain, ytrain.ravel())
  intercepts.append(_format(model.intercept_))

  for i,coef in enumerate(model.coef_):
    coefficients[i].append(_format(coef))

  MSEs.append(_format(mean_squared_error(model.predict(Xtest), ytest)))


method_names.append("Best Subset")
clf = LinearRegression()
subset = _best_subset_cv(clf, Xtrain, ytrain, cv=3)
model = clf.fit(Xtrain[:, subset], ytrain)

for i in range(Xtrain.shape[1]):
  coefficients[i].append(0.00)
for i,coef in enumerate(model.coef_.ravel()):
  coefficients[i][-1] = _format(coef)

intercepts.append(_format(model.intercept_[0]))
MSEs.append(_format(mean_squared_error(model.predict(Xtest[:, subset]), ytest)))


# Write CSV
CSV=[method_names, intercepts]
CSV+=coefficients
CSV.append(MSEs)

with open("prostateComparison.txt", "wb") as f:
  writer = csv.writer(f, delimiter='\t')
  writer.writerows(CSV)
