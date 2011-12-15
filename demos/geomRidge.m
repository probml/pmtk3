% Geometry of Ridge Regression

%{
setSeed(0);
mu = [3; 3];
sigma2 = 1;
Sigma = [3,0;0,1];
N = 100;
X = gaussSample(mu, Sigma, N);
xbar = mean(X);
mleCov = X'*X;
%}

xbar = [3;3];
S = [3,0;0,1];

Mu0 = [0;0];
Sigma0 = eye(2);


hold on;
%axis([-5 8 -4 8], 'nolabel');
axis equal
gaussPlot2d(xbar,S,'color','r');
%gaussPlot2d(xbar,mleCov,'color','r');
gaussPlot2d(Mu0,Sigma0,'color','g');
fs = 14;
text(Mu0(1) + 1/4, Mu0(2), 'prior mean', 'fontsize', fs);

wml = xbar;

%m0 = 2; n = 1;
%wmap = (n*S + m0*Sigma0)\(n*S) * xbar; 
wmap = [1, 2.5]; % artist's rendition


plot(wmap(1), wmap(2), 'b*','linewidth',3);
% text('Interpreter', 'latex', 'String', '$$w_{MAP}$$', 'Position', [wmap(1) + 1/2, wmap(2)]);
text(wmap(1) + 1/4, wmap(2), 'MAP Estimate', 'fontsize', fs);

plot(wml(1), wml(2), 'r*','linewidth',3);
text(wml(1) + 1/4, wml(2) + 1/4, 'ML Estimate', 'fontsize', fs);

line([wml(1),wml(1)+3],[wml(2),wml(2)],'linewidth',3)
text(wml(1)+3,wml(2)+1/2,'u_1', 'fontsize', fs);

line([wml(1),wml(1)],[wml(2),wml(2)+3],'linewidth',3);
text(wml(1)+1/2,wml(2)+3,'u_2', 'fontsize', fs);

axis off
printPmtkFigure('geomRidge')
