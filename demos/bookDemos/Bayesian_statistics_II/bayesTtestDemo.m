%% Bayesian T test demo
%
%% Paired test
% Data from http://en.wikipedia.org/wiki/Student's_t-test

% This file is from pmtk3.googlecode.com

z = [ 30.02, 29.99, 30.11, 29.97, 30.01, 29.99];
y = [ 29.89, 29.93, 29.72, 29.98, 30.02, 29.98];

[BF01, probH0] = bayesTtestOneSample(y-z)
%% Compare to web program (slightly different prior)
% http://pcl.missouri.edu/sites/default/bf/one-sample.php


%% Unpaired (pooled) test
% Data from Gonen et al 2005 sec 4
xbar         = 5; 
ybar         = -0.2727;
Nx           = 10; 
Ny           = 11;
sx           = 8.7433; 
sy           = 5.9007;

%[BF01, probH0] = bayesTtestTwoSample(x,y)
[BF01, probH0] = bayesTtestTwoSample([],[],xbar,ybar,Nx,Ny,sx,sy)


