#!/usr/bin/env python

from utils import preprocessor_create
from utils import poly_data_make
from SupervisedModels.linearRegression import linreg_fit
import numpy as np
import pylab as pl

N = 21
xtrain, ytrain, xtest, _, ytest, _ = poly_data_make(sampling='thibaux', n=N)

degs = np.arange(1, 22)
Nm = len(degs)

# Plot error vs degree
mseTrain = np.zeros(Nm)
mseTest = np.zeros(Nm)
for m in xrange(len(degs)):
    deg = degs[m]
    pp = preprocessor_create(rescale_X=True, poly=deg, add_ones=True)
    model = linreg_fit(xtrain, ytrain, preproc=pp)
#     ypredTrain = linregPredict(model, xtrain)
#     ypredTest = linregPredict(model, xtest)
#     mseTrain[m] = np.mean(np.square(ytrain - ypredTrain))
#     mseTest[m] = np.mean(np.square(ytest - ypredTest))

# ndx = degs <= 16
# fig = pl.figure()
# pl.plot(degs[ndx], mseTrain[ndx])
# pl.plot(degs[ndx], mseTest[ndx])
# pl.xlabel('degree')
# pl.ylabel('mse')
# pl.legend(('train', 'test'))
# pl.savefig('linregPolyVsDegreeUcurve.png')
# pl.show()


# degs = [1, 2, 10, 14, 20]
# mseTrain = np.zeros(len(degs))
# mseTest = np.zeros(len(degs))

# for m, deg in enumerate(degs):
#     pp = preprocessorCreate(rescaleX=True, poly=deg, addOnes=True)
#     model = linregFit(xtrain, ytrain, preproc=pp)
#     ypredTrain = linregPredict(model, xtrain)
#     ypredTest = linregPredict(model, xtest)
#     mseTrain[m] = np.mean(np.square(ytrain - ypredTrain))
#     mseTest[m] = np.mean(np.square(ytest - ypredTest))

#     pl.figure(m)
#     pl.plot(xtrain, ytrain, 'o')
#     pl.plot(xtest, ypredTest, lw=3)
#     pl.title("degree %d" % deg)
#     pl.savefig('polyfitDemo%d.png' % deg)
#     pl.xlim([-1, 21])
#     pl.ylim([-10, 15])
#     pl.show()

#     # figure;
#     # plot(xtrain,ytrain,'.b', 'markersize', 50);
#     # hold on;
#     # plot(xtest, ypredTest, 'k', 'linewidth', 3, 'markersize', 20);
#     # hold off
#     # title(sprintf('degree %d', deg))
#     # set(gca,'ylim',[-10 15]);
#     # set(gca,'xlim',[-1 21]);
#     # printPmtkFigure(sprintf('polyfitDemo%d', deg))    


# #     print deg, np.mean(np.square(ytrain - ypredTrain))

# #     pl.figure(m)
# #     pl.plot(xtrain, ytrain, 'o')
# #     pl.plot(xtrain, ypredTrain)
# #     pl.title("degree %d" % deg)
# #     pl.xlim([-1, 21])
# #     pl.ylim([-10, 15])
# #     pl.savefig('polyfitDemo%d.png' % deg)

# # # logev = np.zeros(len(degs))

# # # for m = xrange(len(degs)):
# # #     deg = degs[m]
# # #     pp = preprocessorCreate(rescaleX=True, poly=deg, addOnes=True)
# # #     xxtrain = degexpand(xtrain, deg, True)
# # #     modelEB, logev[m] = linregFitBayes(xxtrain, ytrain, preproc=pp, prior='eb')

# # # figure;
# # # probs = exp(normalizeLogspace(logev));
# # # plot(degs, logev ,'ko-', 'linewidth', 2, 'markersize', 24);
# # # xlabel('degree'); ylabel('log evidence')
# # # printPmtkFigure('linregPolyVsDegreeLogev')

# # # figure; bar(degs, probs)
# # # xlabel('degree'); ylabel('probability')
# # # printPmtkFigure('linregPolyVsDegreeProbModel')


