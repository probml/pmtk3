function [XX] = kernelLinear(X1,X2,d)
XX = (1+X1*X2').^d;