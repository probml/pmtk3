sam = load('mnistRoweis.mat');%     train0: [5923x784 uint8] 

geoff = load('digit7.mat'); % D: [5923x784 double]

kpm = load('mnistALL.mat'); %mnist.train_images: [28x28x60000 uint8] 

figure(1);clf;ndx = find(kpm.mnist.train_labels==7);
img=kpm.mnist.train_images(:,:,ndx(1));imagesc(img);colormap(gray)

figure(2);clf; imagesc(reshape(sam.train7(1,:),[28 28]));colormap(gray)

figure(3);clf; imagesc(reshape(geoff.D(1,:)',[28 28]));colormap(gray)
