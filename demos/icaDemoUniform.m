%% Comparing ICA and PCA on data from a 2d uniform distribution
%PMTKauthorAapo Hyvarinen
%PMTKdate Sep 2010

% This file is from pmtk3.googlecode.com


%You need to have access to the FastICA package

setSeed(2);
%Number of data points
N=100;
%Choose a nice mixing matrix
A=[2,3;2,1]*.3;


%% Uniform data

%Create data with uniform distribution
Suni=(rand(2,N)*2-1)*sqrt(3);
Xuni=A*Suni;
Vuni = fastica(Xuni,'only','white');
Shat = fastica(Xuni,'g','tanh','approach','symm');

%Sets length of coordinate axes
cmax=3; 

%Plot uniform ICs
figure;
h1=plot(Suni(1,:),Suni(2,:),'.',[-cmax,cmax],[0,0],'k',[0,0],[-cmax,cmax],'k'); 
%just cosmetics:
set(h1,'LineWidth',2);
set(h1,'MarkerSize',16);
axis equal;
title('uniform data')
printPmtkFigure('icaUniformSource')

%Plot uniform mixed data
figure;
h1=plot(Xuni(1,:),Xuni(2,:),'.',[-cmax,cmax],[0,0],'k',[0,0],[-cmax,cmax],'k'); 
axis equal;
set(h1,'LineWidth',2);
set(h1,'MarkerSize',16);
title('uniform data after linear mixing')
printPmtkFigure('icaUniformMixed')


%Plot uniformly distributed data after PCA whitening
figure;
h1=plot(Vuni(1,:),Vuni(2,:),'.',[-cmax,cmax],[0,0],'k',[0,0],[-cmax,cmax],'k'); 
axis equal;
set(h1,'LineWidth',2);
set(h1,'MarkerSize',16);
title('PCA applied to mixed data from uniform source')
printPmtkFigure('icaUniformPCA')


%Plot estimated ICs from uniformly distributed data
figure
h1=plot(Shat(1,:),Shat(2,:),'.',[-cmax,cmax],[0,0],'k',[0,0],[-cmax,cmax],'k'); 
axis equal; 
set(h1,'LineWidth',2);
set(h1,'MarkerSize',16);
title('ICA applied to mixed data from uniform source')
printPmtkFigure('icaUniformICA')


%% Gaussian source

if 0
%Create Gaussian data for comparison
Sgauss=randn(2,N);
Sgauss=Sgauss.*(abs(Sgauss)<5);

Xgauss=A*Sgauss;
Vgauss = fastica(Xgauss,'only','white');

ShatGauss = fastica(Xgauss,'g','tanh','approach','symm');

%Plot original gaussian distribution with independent variables
figure
h1=plot(Sgauss(1,:),Sgauss(2,:),'.',[-cmax,cmax],[0,0],'k',[0,0],[-cmax,cmax],'k'); 
axis off; axis equal;
set(h1,'LineWidth',2);
set(h1,'MarkerSize',16);
title('gaussian data')

%Plot mixtures of  gaussian variables
figure
h1=plot(Xgauss(1,:),Xgauss(2,:),'.',[-cmax,cmax],[0,0],'k',[0,0],[-cmax,cmax],'k'); 
axis off; axis equal;
set(h1,'LineWidth',2);
set(h1,'MarkerSize',16);
title('gaussian data after mixing')


%Plot PCA of gaussian data
figure
hold on
h1=plot(Vgauss(1,:),Vgauss(2,:),'.',[-cmax,cmax],[0,0],'k',[0,0],[-cmax,cmax],'k'); 
axis off; axis equal;
set(h1,'LineWidth',2);
set(h1,'MarkerSize',16);
title('gaussian data after whitening')

%Plot estimated ICs from gaussian distributed data
figure
h1=plot(ShatGauss(1,:),ShatGauss(2,:),'.',[-cmax,cmax],[0,0],'k',[0,0],[-cmax,cmax],'k'); 
axis equal; axis off;
set(h1,'LineWidth',2);
set(h1,'MarkerSize',16);
title('ica applied to mixed data from gaussian source')

end
