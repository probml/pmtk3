%% PCA Face Demo
% Based on code by Mark Girolami
%%

% This file is from pmtk3.googlecode.com

requireImageToolbox
loadData('facesOlivetti');
h = 112; w = 92;

% plot the first 25 faces as a single image
figure;
N = 25;
XtrainImg = zeros(h,w,1,N);
for i = 1:N
  XtrainImg(:,:,1,i) = reshape(Xtrain(i,:), [h w]);
end
montage(XtrainImg); 
title(sprintf('first %d training images', N))
%for i=1:25
%  subplot(5,5,i)
%  f = reshape(X(i,:), [h w]);
%  imagesc(f);
%  axis off
%end
%colormap gray

Selected_Face = 125;%312;%255;

[N,D]=size(X);
mean_face = mean(X);
%X = X - repmat(mean_face,N,1);
fprintf('Performing PCA.... stay tuned\n');
K = 100; 
[B, mu, Xp, Xrecon] = pcaPmtk(X, K);
%tic; [B] = pcaPmtk(X,K); toc
Xproj = X*B;

% visualize basis functions (eigenfaces)
figure;
subplot(2,2,1)
f = reshape(mean_face, [h w]);
imagesc(f);
axis off
for i=1:3
  subplot(2,2,i+1)
  f = reshape(B(:,i), [h w]);
  imagesc(f);
  axis off
end
colormap gray

% visualize reconstruction
figure;
subplot(2,2,1)
%imagesc(reshape(X(Selected_Face,:)+mean_face,h,w));
imagesc(reshape(X(Selected_Face,:),h,w));
title('Original Image');
recon_err=[];
for i=1:K
  X_Reconst=Xproj(Selected_Face,1:i)*B(:,1:i)' + mean_face;
  if i==10
    subplot(2,2,2)
    imagesc(reshape(X_Reconst',h,w)); axis off
    title('Reconstructed Image with 10 bases');drawnow;
  elseif i==100
      subplot(2,2,3)
      imagesc(reshape(X_Reconst',h,w)); axis off
      title('Reconstructed Image with 100 bases');drawnow;
  end
  recon_err = [recon_err;sqrt(mean((X_Reconst - (X(Selected_Face,:) + mean_face) ).^2,2))];
  colormap gray
  subplot(2,2,4)
  plot(1:i,recon_err,'LineWidth',3);
  title('Reconstruction Error');
  fprintf('%d:Reconstruction Error = %f\n',i,recon_err(i))
end
