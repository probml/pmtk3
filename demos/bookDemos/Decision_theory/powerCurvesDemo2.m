%% Power vs sample size for excluding a null value from binary trials

Ns=1:5:100;
nullValue = [];
priorMeans = [0.6 0.7 0.8];
priorN = 10;
widths = [0.25 0.2 0.15];
[styles, colors, symbols, str] =  plotColors();
for i=1:numel(widths)
  maxWidth = widths(i);
  figure; hold on
  for j=1:numel(priorMeans)
    priorMean = priorMeans(j);
    power = powerCurves(priorMean, priorN, nullValue, maxWidth, Ns);
    plot(Ns, power, sprintf('%s%s', styles{j}, colors(j)), 'linewidth', 3);
    legendStr{j}= sprintf('priorMean = %5.3f', priorMean);
  end
  legend(legendStr ,'location', 'northwest');
  xlabel('N'); ylabel('power')
  title(sprintf('desired width = %5.3f', maxWidth))
  set(gca,'ylim',[0 1]);grid on
  drawnow
  printPmtkFigure(sprintf('powerCurvesDemo2-width%d', i));
end