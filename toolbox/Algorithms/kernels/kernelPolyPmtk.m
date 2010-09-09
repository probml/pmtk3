
% This file is from pmtk3.googlecode.com

function [K] = kernelPolyPmtk(X1,X2,d)
K = (1+X1*X2').^d;
end
