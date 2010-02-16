xs = -1:0.01:1;
%deltas = [1 1 0.1, 0.1];
%cs = [1 0.1 1 0.1];

deltas = [0.01 0.75 1 2];
cs = ones(1,4);
f1=figure; hold on
[styles, colors, symbols] =  plotColors;
for i=1:length(deltas)
  delta = deltas(i);
  c = cs(i);
  logp{i} = normalGammaLogpdf(xs, delta, c);
  pr = exp(logp{i});
  str{i} = sprintf('%s=%3.2f, %s=%3.2f', '\delta', delta, 'c', c);
  plot(xs, pr, styles{i}, 'linewidth', 2);
end
legend(str)
title('pdf of normalGamma distribution')
printPmtkFigure('normalGamma')

figure; hold on
for i=1:length(deltas)
  plot(xs, logp{i}, styles{i}, 'linewidth', 2);
end
legend(str)
title('logpdf of normalGamma distribution')
printPmtkFigure('normalGammaLog')