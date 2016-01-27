load facesCBCL
[nr nc N] = size(X);
K=100; montage(reshape(X(:,:,1:K),[nr nc 1 K]))
 