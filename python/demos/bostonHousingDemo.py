# Boston housing demo

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import sklearn
import scipy.io

from sklearn.datasets import load_boston
from sklearn.preprocessing import StandardScaler
from sklearn.linear_model import LinearRegression
from sklearn.cross_validation import train_test_split, cross_val_score
from sklearn import metrics

# Prevent numpy from printing too many digits
np.set_printoptions(precision=3)

# Load data
boston = load_boston()
X = boston.data
y = boston.target

# Save to matlab format for later use
#fname = '/Users/kpmurphy/github/pmtkdata/bostonHousing/boston.mat'
#dict = {'X':X, 'y':y, 'names':boston.feature_names};
#scipy.io.savemat(fname, dict)

# plot all of the data (13 features, 1 response)
nrows = 7; ncols = 2;
#fig = plt.figure(figsize=[15,10])
fig, axes = plt.subplots(nrows=nrows, ncols=ncols, figsize=[15,10])
plt.tight_layout()
plt.clf()
for i in range(0,13):
    subplot(nrows, ncols, i+1)
    hist(X[:,i])
    title(boston.feature_names[i])
    plt.locator_params(axis = 'y', nbins = 3) # fewere yticks
subplot(nrows, ncols, 14)
hist(y)
title('Median price ($1000 USD)')
plt.show()
plt.locator_params(axis = 'y', nbins = 3)

# Fit model
scaler = StandardScaler()
scaler = scaler.fit(X)
X = scaler.transform(X)

linreg = LinearRegression()
linreg.fit(X, y)

# Extract parameters
coef = np.append(linreg.coef_, linreg.intercept_)
names = np.append(boston.feature_names, 'intercept')
print([name + ':' + str(round(w,1)) for name, w in zip(names, coef)])

# Assess fit on training set
yhat = linreg.predict(X) 
plt.scatter(y, yhat)
plt.xlabel("true price")
plt.ylabel("predicted price")
plt.title("Predicted vs true house price (x $1000 USD) for Boston, 1978")
xs = np.linspace(min(y), max(y), 100)
plt.plot(xs, xs, '-')

print "R^2 on training set is {0:0.3f}".format(linreg.score(X,y))

# evaluate the model using 10-fold cross-validation
scores = cross_val_score(LinearRegression(), 
            X, y, scoring='r2', cv=10)
print scores
print "Median R^2 across CV folds is {0:0.3f}".format(median(scores))

# Direct implementation of OLS (unfinished)
N = X.shape[0]
X1 = np.append(X, np.ones(N)



