%% Baseball Batting Average Shrinkage Estimates
% Reproduce example from
% "Data Analysis Using Stein's Estimator and its Generalizations"
% Bradley Efron; Carl Morris JASA Vol. 70, No. 350. (Jun., 1975), pp.
% 311-319.
%% Data
% 1970 batting averages for 18 major league players. 
% first column = batting average for first 45 at bats
% 2nd column   = batting everage for remainder of season

% This file is from pmtk3.googlecode.com

data = [0.400 0.346;
     0.378 0.298
     0.356 0.276
     0.333 0.222
     0.311 0.273
     0.311 0.270
     0.289 0.263
     0.267 0.210
     0.244 0.269
     0.244 0.230
     0.222 0.264
     0.222 0.256
     0.222 0.303
     0.222 0.264
     0.222 0.226
     0.200 0.285
     0.178 0.316
     0.156 0.200];
%% Data Transformation
y = data(:,1);
ytest = data(:,2);
n = 45;
x = sqrt(n)*asin(2*y-1); % arcsin transform
%% Shrinkage estimate
d = length(x);
xbar = mean(x);
V    = sum((x-xbar).^2);
s2   = V/d;
%B = (d-3)/V;% Efron-Morris shrinkage
sigma2 = 1; % by construction of the arcsin transform
B = sigma2/(sigma2 + max(0, s2-sigma2)); % B = lambda0
muShrunk = xbar + (1-B)*(x-xbar); 
%% Back transform
thetaShrunk = 0.5*(sin(muShrunk/sqrt(n))+1); 
thetaMLE = y;

%% Plot Shrinkage Estimates
figure;
plot(thetaMLE, ones(1, d) ,'o');
hold on
plot(thetaShrunk, 0*ones(1, d), 'o');
for i=1:d
  line([thetaMLE(i); thetaShrunk(i)], [1; 0]);
end
title('MLE (top) and shrinkage estimates (bottom)')
printPmtkFigure shrinkageDemoBaseballParams; 
%% Histograms
figure;
ndx = 1:5;
h = bar([ytest(ndx)';   thetaShrunk(ndx)'; thetaMLE(ndx)']');
legend({'true',  'shrunk', 'MLE'})
%[im_hatch, colorlist] = applyhatch_pluscolor(gcf,'\-x.', 1);
mseMLE = mean((ytest-thetaMLE).^2);
mseShrink = mean((ytest-thetaShrunk).^2);
ttl = sprintf('MSE MLE = %6.4f, MSE shrunk = %6.4f', mseMLE, mseShrink)
title(ttl)
xlabel('player number')
ylabel('MSE')
printPmtkFigure shrinkageDemoBaseballPred; 
mseMLE/mseShrink
