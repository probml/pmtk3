function [F] = logisticInversecdf(p,a,b)
F = a + b*(log(p)-log(1-p));