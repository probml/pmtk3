#!/usr/bin/python2.4
import numpy
import scipy.stats
import matplotlib.pyplot as plt

def main():
    # true parameters
    w  = 2
    w0 = 3
    sigma = 2

    # make data
    numpy.random.seed(1)
    Ntrain = 20
    xtrain = numpy.linspace(0,10,Ntrain)
    ytrain = w*xtrain + w0 + numpy.random.random(Ntrain)*sigma
    Ntest = 100
    xtest = numpy.linspace(0,10,Ntest)
    ytest = w*xtest + w0 + numpy.random.random(Ntest)*sigma
    
    #  from http://www2.warwick.ac.uk/fac/sci/moac/students/peter_cock/python/lin_reg/
    # fit
    west, w0est, r_value, p_value, std_err = scipy.stats.linregress(xtrain, ytrain)

    # display
    print "Param \t True \t Est"
    print "w0 \t %5.3f \t %5.3f" % (w0, w0est)
    print "w \t %5.3f \t %5.3f" % (w, west)

    # plot
    plt.close()
    plt.plot(xtrain, ytrain, 'ro')
    plt.hold(True)
    #plt.plot(xtest, ytest, 'ka-')
    ytestPred = west*xtest + w0est
    #ndx = range(0, Ntest, 10)
    #h = plt.plot(xtest[ndx], ytestPred[ndx], 'b*')
    h = plt.plot(xtest, ytestPred, 'b-')
    plt.setp(h, 'markersize', 12)

if __name__ == '__main__':
	main()
