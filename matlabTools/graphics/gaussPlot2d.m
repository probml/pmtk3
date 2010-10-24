function h=gaussPlot2d(mu, Sigma, varargin)
% Plot an ellipse representing the covariance matrix of a Gaussian
% 

% This file is from pmtk3.googlecode.com

if size(Sigma) ~= [2 2], error('Sigma must be a 2 by 2 matrix'); end
[color, plotMarker] = process_options(varargin, 'color', 'r', 'plotMarker', true);

mu = mu(:);
[U, D] = eig(Sigma);
n = 100;
t = linspace(0, 2*pi, n);
xy = [cos(t); sin(t)];
%k = sqrt(chi2inv(0.95, 2)); % 5.99
k = sqrt(6);
w = (k * U * sqrt(D)) * xy;
z = repmat(mu, [1 n]) + w;
h = plot(z(1, :), z(2, :), color, 'linewidth', 2);
hold on
if plotMarker
  hh=plot(mu(1), mu(2),  'x');
  set(hh,'color',color, 'linewidth', 2,  'markersize', 13);
end
%axis('equal');    
end
