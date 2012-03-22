%% Demo of monte carlo integration for estimating pi
%
%%

% This file is from pmtk3.googlecode.com

r=2;
S=5000;
xs = unifrndPMTK(-r,r,S,1);
ys = unifrndPMTK(-r,r,S,1);
rs = xs.^2 + ys.^2;
inside = (rs <= r^2);
samples = 4*(r^2)*inside;
Ihat = mean(samples)
piHat = Ihat/(r^2)
se = sqrt(var(samples)/S)

figure(1);clf
outside = ~inside;
plot(xs(inside), ys(inside), 'bo');
hold on
plot(xs(outside), ys(outside), 'rx');
axis square
axis([-2.03 2.03 -2.03 2.03])
printPmtkFigure('mc-pi'); 
