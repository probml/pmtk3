loadData('Ximg')
[nRows,nCols] = size(X);

y = 2-X;
ysub = y(1:16,1:16);
ysub(ysub==2) = 3;
y(1:16,1:16) = ysub;
ysub = y(1:16,17:end);
ysub(ysub==2) = 4;
y(1:16,17:end) = ysub;

Xrgb = ones(nRows,nCols,3);
Xrgb(:,:,2) = Xrgb(:,:,2) - (y==2);
Xrgb(:,:,3) = Xrgb(:,:,3) - (y==2);
Xrgb(:,:,1) = Xrgb(:,:,1) - (y==3);
Xrgb(:,:,3) = Xrgb(:,:,3) - (y==3);
Xrgb(:,:,1) = Xrgb(:,:,1) - (y==4);
Xrgb(:,:,2) = Xrgb(:,:,2) - (y==4);

save('XimgRgb', 'Xrgb', 'y')