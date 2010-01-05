% Make a point move in the 2D plane
% State = (x y xdot ydot). We only observe (x y).

% This code was used to generate Figure 15.9 of "Artificial Intelligence: a Modern Approach",
% Russell and Norvig, 2nd edition, Prentice Hall, 2003.

% X(t+1) = F X(t) + noise(Q)
% Y(t) = H X(t) + noise(R)

ss = 4; % state size
os = 2; % observation size
F = [1 0 1 0; 0 1 0 1; 0 0 1 0; 0 0 0 1]; 
H = [1 0 0 0; 0 1 0 0];
Q = 0.001*eye(ss);
R = 1*eye(os);
initx = [10 10 1 0]';
initxBel = [8 10 1 0]';
initV = 1*eye(ss);

seed = 9;
rand('state', seed);
randn('state', seed);
T = 15;
[x,y] = kalmanSample(F, H, Q, R, initx, T);

[xfilt, Vfilt, VVfilt, loglik] = kalmanFilter(y, F, H, Q, R, initxBel, initV);
[xsmooth, Vsmooth] = kalmanSmoother(y, F, H, Q, R, initx, initV);

dfilt = x([1 2],:) - xfilt([1 2],:);
mse_filt = sqrt(sum(sum(dfilt.^2)))

dsmooth = x([1 2],:) - xsmooth([1 2],:);
mse_smooth = sqrt(sum(sum(dsmooth.^2)))


figure;
%subplot(2,1,1)
hold on
plot(y(1,:), y(2,:), 'g*',  'linewidth', 3, 'markersize', 12);
plot(x(1,:), x(2,:), 'ks-', 'linewidth', 3, 'markersize', 12);
legend('observed', 'truth')
axis equal
printPmtkFigure('kalmanTrackingTruth')

figure;
hold on
plot(y(1,:), y(2,:), 'g*',  'linewidth', 3, 'markersize', 12);
plot(xfilt(1,:), xfilt(2,:), 'rx-',  'linewidth', 3, 'markersize', 12);
for t=1:T, plotgauss2d(xfilt(1:2,t), 0.1*Vfilt(1:2, 1:2, t)); end
hold off
legend('observed', 'filtered')
axis equal
printPmtkFigure('kalmanTrackingFiltered')

figure;
%subplot(2,1,2)
hold on
plot(y(1,:), y(2,:), 'g*', 'linewidth', 3, 'markersize', 12);
plot(xsmooth(1,:), xsmooth(2,:), 'rx-', 'linewidth', 3, 'markersize', 12);
for t=1:T, plotgauss2d(xsmooth(1:2,t), 0.1*Vsmooth(1:2, 1:2, t)); end
hold off
legend('observed', 'smoothed')
axis equal
printPmtkFigure('kalmanTrackingSmoothed')
