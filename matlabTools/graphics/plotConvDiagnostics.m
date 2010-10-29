function plotConvDiagnostics(X,  ttl, filename, maxAcf)
% Plot trace plot, smoothed trace plot, and ACF of 1d quantity
% X(samples, chain/seed)

if nargin < 3, filename = []; end
if nargin < 4, maxAcf = 20; end

% This file is from pmtk3.googlecode.com

if nargin < 2, ttl = ''; end
nseeds = size(X,2);
colors = {'r', 'g', 'b', 'k'};

% Trace plots
%h=figure; set(h,'name', ttl);
figure;
hold on;
for i=1:nseeds
  plot(X(:,i), colors{i});
end
Rhat = epsr(X(:,:));
title(sprintf('%s, Rhat = %5.3f', ttl, Rhat))
if ~isempty(filename), printPmtkFigure(sprintf('%s-traceplot', filename)); end

% Smoothed trace plots
figure; hold on
for i=1:nseeds
  movavg = filter(repmat(1/50,50,1), 1, X(:,i));
  plot(movavg,  colors{i});
end
title(sprintf('%s, Rhat = %5.3f', ttl, Rhat))
if ~isempty(filename), printPmtkFigure(sprintf('%s-traceplotSmoothed', filename)); end

% Plot auto correlation function for 1 chain
figure;
stem(acf(X(:,1), maxAcf));
title(ttl)
if ~isempty(filename), printPmtkFigure(sprintf('%s-acf', filename)); end

end
    
