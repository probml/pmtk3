function  mnistSplit()

%Put each digit into its own file


% train_images: [28x28x60000 uint8]
% test_images: [28x28x10000 uint8]
% train_labels: [60000x1 uint8]
% test_labels: [10000x1 uint8]

load('mnistALL.mat');
for c=1:10
  y = c; if y==10, y=0; end
  ndx = find(mnist.train_labels==y);
  Ntrain(c) = length(ndx)
  Xtrain = double(reshape(mnist.train_images(:,:,ndx), [28*28 length(ndx)])');
  ndx = find(mnist.test_labels==y);
  Ntest(c) = length(ndx)
  Xtest = double(reshape(mnist.test_images(:,:,ndx), [28*28 length(ndx)])');
  folder = 'C:\kmurphy\BLT\BLT\Data';
  fname = fullfile(folder, sprintf('mnist%d.mat', y));
  save(fname, 'Xtrain', 'Xtest');
end
Ntrain
Ntest

%{
Ntrain =
  Columns 1 through 7
        6742        5958        6131        5842        5421        5918        6265
  Columns 8 through 10
        5851        5949        5923
Ntest =
  Columns 1 through 7
        1135        1032        1010         982         892         958        1028
  Columns 8 through 10
         974        1009           980
%}