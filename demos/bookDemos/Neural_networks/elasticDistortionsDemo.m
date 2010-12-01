%% Illustrate elastic deformations
%PMTKauthor Kevin Swersky

load goodsix.mat

setSeed(2);
%rand('seed',30);
cm = ones(64,3);
cm(:,1:2) = repmat(linspace(1,0,size(cm,1))',1,2);
X = repmat(1:size(I,2),size(I,1),1);
Y = repmat([1:size(I,1)]',1,size(I,2));

%{
figure;
imagesc(I);colormap(cm)
set(gca,'XTickLabel','')
set(gca,'YTickLabel','')
axis([0,29,0,29]);
%}
%sigs = [0.1 1 8];
sigs = [5 5 5 5]; % if large (say 100), field flows in same direction
%alphas = [8 4 32];
alphas = [10 10 30 30];
for i=1:numel(sigs)
  sig = sigs(i);
  alpha = alphas(i);
  filterwidth = 101;
  [Dx,Dy] = create_distortion_map(I,sig,alpha,filterwidth);
  I2 = distort_image(I,Dx,Dy);
  
  figure;
  imagesc(I2);colormap(cm)
  set(gca,'XTickLabel','')
  set(gca,'YTickLabel','')
  axis([0,28,0,28]);
  printPmtkFigure(sprintf('elasticDistortionDigit%d', i));
  
  figure;
  quiver(X,Y,-Dx,Dy);
  set(gca,'XTickLabel','')
  set(gca,'YTickLabel','')
  axis([0,29,0,29]);
  printPmtkFigure(sprintf('elasticDistortionQuiver%d', i));
end


