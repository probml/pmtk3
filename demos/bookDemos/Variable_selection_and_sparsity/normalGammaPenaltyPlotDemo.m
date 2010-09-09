%% Plot contours of penalty(w1) + penalty(w2), where penalty(w) = -log p(w)
% and p(w) = normalGamma(w | delta, c)
% PMTKauthor Francois Caron
% PMTKmodified Kevin Murphy
%%

% This file is from pmtk3.googlecode.com

function normalGammaPenaltyPlotDemo()
c = 1;
pas=0.01;
%[X,Y] = meshgrid(-1:pas:1,-1:pas:1.1);
range= [-1:0.01:-0.9, -0.9:0.1:-0.1, -0.1:0.01:0.1, 0.1:0.1:0.9, 0.9:0.01:1];
[X,Y] = meshgrid(range, range);
[styles, colors, symbols] =  plotColors; %#ok
deltas = [0.01 0.75 1 2];


if 1
figure; hold on
for i=1:length(deltas)
  delta = deltas(i);
   pen = @(X) normalGammaNeglogpdf(X, delta, c);
  Z=pen(X(:)) + pen(Y(:)) - pen(1) - pen(pas);
  str{i} = sprintf('%s=%3.2f, c=1', '\delta', delta);
  cout = contour(X, Y, reshape(Z, size(X)), [0 0], styles{i}, ...
    'color', colors(i),   'linewidth', 3, 'displayname', str{i}); % 'name', str{i});
  %set(h(i), 'color', colors(i));
  h(i) = plot(0, 0, [styles{i}, colors(i)], 'linewidth', 3); 
end
legend(h, str)
title(sprintf('penalty induced by normalGamma(%s,c) prior', '\delta'))
printPmtkFigure('normalGammaPenalty')
end

if 0
  %  slower
figure; hold on
for i=1:length(deltas)
  delta = deltas(i);
  pen = @(X) normalExpGammaNeglogpdf(X, delta, c);
  Z=pen(X) + pen(Y) - pen(1) - pen(pas);
  contour(X,Y,Z,[0,0], styles{i}, 'linewidth', 2);
  str{i} = sprintf('%s=%3.2f, c=1', '\delta', delta);
end
legend(str)
title(sprintf('penalty induced by NEG(%s,c) prior', '\delta'))
printPmtkFigure('NEGPenalty')
end
  

end
