function [model, yhat, loglikHist] = linregCensoredFitEm(X, y, censored, varargin)
%% Fit a censored model by EM
% X: N*D matrix
% y: N*1 vector
%  censored(i) = true if censored
%
% yhat(i) = E[z(i)] computed during EM
%PMTKauthor Hannes Bretschneider 
%PMTKmodified Matt Dunham
%%

% This file is from pmtk3.googlecode.com

X = addOnes(X); 
model.censored = censored; 
[model, loglikHist] = emAlgo(model, [X, y], @init, @estep, @mstep, ...
    varargin{:}); 
yhat = y;
yhat(censored) = model.Ez;
end

function model = init(model, data, restartNum) %#ok
%% Initialize   
X = data(:, 1:end-1);
y = data(:, end); 
w = X\y;
model.sigma = std(y-X*w);
model.w = w;
end

function [ess, sigma] = estep(model, data)
%% Compute the expected sufficient statistics
X = data(:, 1:end-1);
y = data(:, end);     
w = model.w; 
sigma = model.sigma; 
mu    = X*w;
muCen = mu(model.censored); 
c     = y(model.censored); 
H     = @(u)gaussProb(u, 0, 1)./(1-gausscdf(u, 0, 1));
Ez    = muCen + sigma*H((c-muCen)./sigma);
Ez2   = muCen.^2 + sigma^2 + sigma*(c+muCen).*H((c-muCen)./sigma);
ess   = structure(Ez, Ez2, X, y); 
end

function model = mstep(model, ess)
%% Maximize
censored   = model.censored;
uncensored = ~censored; 
Ez  = ess.Ez; 
Ez2 = ess.Ez2;
X   = ess.X; 
y   = ess.y; 
n   = length(y); 
Y   = [y(uncensored); Ez];
w   = X\Y;
mu  = X*w;
sigma2 = 1/n*(sum((y(uncensored)-mu(uncensored)).^2)+...
             sum(Ez2-2.*mu(censored).*Ez + mu(censored).^2));
model.w     = w;
model.sigma = sqrt(sigma2); 
model.Ez    = Ez; 
end
