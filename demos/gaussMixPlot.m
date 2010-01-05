%% Plot a Mixture of Gaussians
%#testPMTK
mu1 = [0.22 0.45]';
mu2 = [0.5 0.5]';
mu3 = [0.77 0.55]';
Sigma1 = [0.018  0.01 ;  0.01 0.011];
Sigma2 = [0.011 -0.01 ; -0.01 0.018];
Sigma3 = Sigma1;
dists = {MvnDist(mu1,Sigma1),MvnDist(mu2,Sigma2),MvnDist(mu3,Sigma3)};
mix = DiscreteDist('-T',[0.5 0.3 0.2]');
mixmat = pmf(mix);
%m = MvnMixDist('nmixtures',3,'distributions',dists,'mixingWeights',mix);
m = MixtureModel('-mixtureComps',dists,'-mixingDist',mix);
figure; hold on;
colors = {'r', 'g', 'b'};
for k=1:3
    mk = m.mixtureComps{k}; % m.distributions{k};
    [h]=plot(mk, 'useContour', true, 'npoints', 200,'scaleFactor',mixmat(k));
    set(h, 'color', colors{k});
end
axis tight;
printPmtkFigure('mixgauss3Components')


figure;
h=plot(m, 'useLog', false, 'useContour', true, 'npoints', 200);
axis tight;
printPmtkFigure('mixgauss3Contour'); 


figure;
h=plot(m, 'useLog', false, 'useContour', false, 'npoints', 200);
brown = [0.8 0.4 0.2];
set(h,'FaceColor',brown,'EdgeColor','none');
hold on;
view([-27.5 30]);
camlight right;
lighting phong;
axis off;
axis tight;
printPmtkFigure('mixgauss3Surf');

X = sample(m, 1000);
figure;
h=plot(m, 'useLog', false, 'useContour', true, 'npoints', 200);
hold on
plot(X(:,1), X(:,2), '.');
axis tight;
printPmtkFigure('mixgauss3Samples'); 
