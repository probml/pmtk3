function K = kernelRbfGamma(X1, X2, gamma)
% K(i, j) = exp(-gamma ||X1(i,:) - X2(j,:)||^2 )

% This file is from pmtk3.googlecode.com


%Z = sqrt(gamma/pi);
K = exp(-gamma * sqDistance(X1, X2)); 

end
