%% Denoise some MNIST digits using a binary RBM
%PMTKauthor Andrej Karpathy
%PMTKmodified Kevin Murphy

% This file is from pmtk3.googlecode.com


setSeed(0);

if 0
load mnistSubset;
% data is 5000*784, testdata is 1000*784 both are in [0,1]
% labels(i) in 1..10, testlabels(i) in 1..10
Xtrain = data; Xtest = testdata;
end

Ntrain = 1000; Ntest = 100; keepSparse = false;
[Xtrain, ytrain, Xtest, ytest] = setupMnist('binary', true, 'ntrain',...
    Ntrain,'ntest', Ntest,'keepSparse', keepSparse);

  Nhidden = 100;
tic
m2= rbmFit(Xtrain, Nhidden, 'verbose', true, 'maxepoch', 20);
toc

%distort 100 images around by setting 5% to random noise
imgs = Xtest(1:100,:);
noiseLevel = 0.1;
mask = rand(size(imgs))<noiseLevel;
noised = imgs;
%r=rand(size(imgs));
%noised(mask)=r(mask);
r=rand(size(imgs)) > 0.5;
noised(mask)=r(mask);

%reconstruct the images by going up down then up again using learned model
%up = rbmVtoH(m2, noised);
%down= rbmHtoV(m2, up);

down = rbmReconstruct(m2, noised);
z1=rbmPlotImg(noised', false);
z2=rbmPlotImg(down', false);

figure;
imshow([z1 z2])
title(sprintf('denoising %5.2f pc noise with RBM with 100 hidden units', ...
  100*noiseLevel))
drawnow;
printPmtkFigure('rbmDenoiseDemo')

%{
% Now fit mixture of bernoullis - this is terrible
K = 10;
Xtrain12 = Xtrain+1; % Xtrain(i,j) in {1,2}
mmodel  = mixModelFit(Xtrain12, K, 'discrete', 'verbose', true);
if 0
for k=1:K,
  figure;img=reshape(T(k,1,:), [28 28]); imagesc(img); colormap('gray');
  title(sprintf('%d',k)); 
end
end

noised12 = noised+1; 
[Xrecon, Zhat] = mixModelReconstruct(mmodel, noised12);
%[Xrecon, Zhat] = mixModelReconstruct(mmodel, Xtrain12(1:100,:));
z3 = rbmPlotImg(Xrecon');
figure;
%imshow([z3])
imshow([z1 z2 z3])
%}
