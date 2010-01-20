function [XX] = kernelRBF(X1,X2,sigma)
n1 = size(X1,1);
n2 = size(X2,1);

Z = 1/sqrt(2*pi*sigma^2);
XX = zeros(n1,n2);
for i = 1:n1
    for j = 1:n2
        dist = sum((X1(i,:)-X2(j,:)).^2);
        XX(i,j) = Z*exp(-dist/(2*sigma^2));
    end
end