function K = kernelRbfSigma(X1, X2, sigma)
% K(i,j) = exp(-1/(2*sigma^2)  ||X1(i,:) - X2(j,:)||^2 )

% This file is from pmtk3.googlecode.com

Z = 1/sqrt(2*pi*sigma^2);
S = sqDistance(X1,X2);
K = Z*exp(-1/(2*sigma^2) * S); % match minfuncDemo behavior
end
