function plotConvDiagnostics(X,  ttl)
% Plot trace plot, smoothed trace plot, and ACF of 1d quantity
% X(samples, chain/seed)
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

% Smoothed trace plots
figure; hold on
for i=1:nseeds
  movavg = filter(repmat(1/50,50,1), 1, X(:,i));
  plot(movavg,  colors{i});
end
title(sprintf('%s, Rhat = %5.3f', ttl, Rhat))

% Plot auto correlation function for 1 chain
figure;
stem(acf(X(:,1), 20));
title(ttl)
end
    