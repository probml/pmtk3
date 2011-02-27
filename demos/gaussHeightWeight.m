%% Gauss Height Weight Demo in 2d
%
%%

% This file is from pmtk3.googlecode.com

rawdata = loadData('heightWeight'); % comma delimited file
data.Y = rawdata(:,1); % 1=male, 2=female
data.X = [rawdata(:,2) rawdata(:,3)]; % height, weight
maleNdx = find(data.Y == 1);
femaleNdx = find(data.Y == 2);
classNdx = {maleNdx, femaleNdx};

% Raw data
figure;
h=scatter(data.X(:,1), data.X(:,2), 100, 'o');
xlabel('height'); ylabel('weight')
printPmtkFigure('heightWeightScatterNoLabels')
   
% Color coded by class
figure;
colors = 'br';
sym = 'xo';
for c=1:2
  str = sprintf('%s%s', sym(c), colors(c));
  X = data.X(classNdx{c},:);
  h=scatter(X(:,1), X(:,2), 100, str); %set(h, 'markersize', 10);
  hold on;
end
xlabel('height'); ylabel('weight')
title('red = female, blue=male');
printPmtkFigure('heightWeightScatter')

% Superimpose Gaussian fits
for c=1:2
  X = data.X(classNdx{c},:);
  mu = mean(X); Sigma = cov(X);
  gaussPlot2d(mu, Sigma, 'color', colors(c));
end
printPmtkFigure('heightWeightScatterCov')

 


