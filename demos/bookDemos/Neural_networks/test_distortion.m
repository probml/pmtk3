function test_distortion(I,sig,alpha,gausswidth)
[Dx,Dy] = create_distortion_map(I,sig,alpha,gausswidth);
I2 = distort_image(I,Dx,Dy);
X = repmat(1:size(I,2),size(I,1),1);
Y = repmat([1:size(I,1)]',1,size(I,2));
figure(1);
subplot(1,3,1); imagesc(I); subplot(1,3,2); imagesc(I2); colormap(gray);
subplot(1,3,3); quiver(X,Y,-Dx,Dy);