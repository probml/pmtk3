function [ model, yhat ] = linregCensoredFitEm( x, y, censored, relTol )
%LINREGCENSOREDEM Fit a censored model by EM
% X: N*D matrix
% y: N*1 vector
%  censored(i) = true if censoreds
%   relTol: relative Tolerance to end the iteration. Defaults to 10^-6
% 
% yhat(i) = E[z(i)] computed during EM

%author Hannes Bretschneider

if nargin < 4
    relTol = 10^-6;
end

n = size(x,1);
x = [ones(n,1) x];
w = x\y;
sigma = std(y-x*w);
w_diff = inf;
iter = 0;
while (w_diff > relTol)
    iter = iter+1;
    mu = x*w;
    [Ez Ez2] = Estep(mu(censored), sigma, y(censored));
    w_old = w;
    [w sigma] = Mstep(x, y, censored, Ez, Ez2);
    w_diff = max(abs(w_old./w-1));
end
model = struct('w', w, 'sigma', sigma);
yhat = y;
yhat(censored) = Ez;
end

function [Ez Ez2] = Estep(mu, sigma, c)
H = @(u)normpdf(u, 0, 1)./(1-normcdf(u, 0, 1));
Ez = mu + sigma*H((c-mu)./sigma);
Ez2 = mu.^2 + sigma^2 + sigma*(c+mu).*H((c-mu)./sigma);
end

function [w sigma] = Mstep(x, y, censored, Ez, Ez2)
n = length(y);
uncensored = ~censored;
Y = [y(uncensored); Ez];
w = x\Y;
mu = x*w;
sigma2 = 1/n*(sum((y(uncensored)-mu(uncensored)).^2)+...
  sum(Ez2-2.*mu(censored).*Ez + mu(censored).^2));
sigma = sqrt(sigma2);
end