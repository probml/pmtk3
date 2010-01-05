function K = rbfKernel(X1, X2, sigma)
% K(i,j) = exp(-1/(2*sigma^2)  ||X1(i,:) - X2(j,:)||^2 )

S = sqdist(X1',X2');
%K = exp(-1/(2*sigma^2) * S);
K = exp(-(1/sigma^2) * S);

