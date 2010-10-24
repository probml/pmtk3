function [xtrain, ytrain, xtest, ytestNoisefree, ytestNoisy, sigma2] = polyDataMake(varargin)
%% Sample Data

% This file is from pmtk3.googlecode.com

[sampling, deg, n] = process_options(varargin, ...
    'sampling', 'sparse', 'deg', 3, 'n', 21);
setSeed(0);
switch sampling
    case 'irregular', xtrain = [-1:0.1:-0.5,  3:0.1:3.5]';
    case 'sparse',    xtrain = [-3, -2, 0, 2, 3]';
    case 'dense',     xtrain = [-5:0.6:5]'; %[-5:0.4:5]';
    case 'thibaux',   xtrain = linspace(0,20,n)';
end
if strcmp(sampling, 'thibaux')
    randn('state', 654321);
    xtest = [0:0.1:20]';
    sigma2 = 4;
    w = [-1.5; 1/9];
    fun = @(x) w(1)*x + w(2)*x.^2;
else
    %xtest = [-5:0.1:5]';
    xtest = [-7:0.1:7]';
    if deg==2
        fun = @(x) (10 + x + x.^2);
    elseif deg==3
        fun = @(x) (10 + x + x.^3);
    else
        error(['bad degree, dude ' deg])
    end
    %sigma2 = 1^2;
    sigma2 = 5^2;
end
ytrain = feval(fun, xtrain) + randn(size(xtrain,1),1)*sqrt(sigma2);
ytestNoisefree = feval(fun, xtest);
ytestNoisy = ytestNoisefree +  randn(size(xtest,1),1)*sqrt(sigma2);
restoreSeed;


