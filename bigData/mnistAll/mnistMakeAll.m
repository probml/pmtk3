% makes the following structure, called mnist
%    train_images: [28x28x60000 uint8]
%     test_images: [28x28x10000 uint8]
%    train_labels: [60000x1 uint8]
%     test_labels: [10000x1 uint8]
% Remember to convert to double before processing

[train_images, train_labels, test_images, test_labels] = mnistRead();

mnist.train_images = train_images;
mnist.test_images = test_images;
mnist.train_labels = train_labels;
mnist.test_labels = test_labels;
save('mnistALL.mat','mnist')

