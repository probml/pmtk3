function [train_images, train_labels, test_images, test_labels] = mnistRead()
% mnistRead Read in MNIST digit set in Le Cun's format
% function [trainImages, trainLabels, testImages, testLabels] = readMNIST()
%
% The data is available at
% http://yann.lecun.com/exdb/mnist/ 
% 
% OUTPUT:
% trainImages(:,:,i) is a uint8 matrix of size 28x28x60000
%         0 = background, 255 = foreground
% trainLabels(i) - 60000x1 uint8 vector
% testImages(:,:,i) size 28x28x10,000
% testLabels(i)
%
% Use mnistShow(trainImages, trainLabels) to visualize data.
%
% This function was originally written by Bryan Russell
% www.ai.mit.edu/~brussell
% Modified by Kevin Murphy, 9 February 2004
% www.ai.mit.edu/~murphyk

fid = fopen('train-images-idx3-ubyte','r','ieee-be'); % big endian
A = fread(fid,4,'uint32');
num_images = A(2);
mdim = A(3);
ndim = A(4);

train_images = fread(fid,mdim*ndim*num_images,'uint8=>uint8');
train_images = reshape(train_images,[mdim, ndim,num_images]);
train_images = permute(train_images, [2 1 3]); 

fclose(fid);


fid = fopen('train-labels-idx1-ubyte','r','ieee-be');
A = fread(fid,2,'uint32');
num_images = A(2);

train_labels = fread(fid,num_images,'uint8=>uint8');

fclose(fid);


% Test

fid = fopen('t10k-images-idx3-ubyte','r','ieee-be');
A = fread(fid,4,'uint32');
num_images = A(2);
mdim = A(3);
ndim = A(4);

test_images = fread(fid,mdim*ndim*num_images,'uint8=>uint8');
test_images = reshape(test_images,[mdim, ndim,num_images]);
test_images = permute(test_images, [2 1 3]); 

fclose(fid);

% Testing labels:
fid = fopen('t10k-labels-idx1-ubyte','r','ieee-be');
A = fread(fid,2,'uint32');
num_images = A(2);

test_labels = fread(fid,num_images,'uint8=>uint8');

fclose(fid);
