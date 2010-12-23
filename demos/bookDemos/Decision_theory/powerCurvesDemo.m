%% Power vs sample size for excluding a null value from binary trials

Ns=1:5:100;
nullValue = [];
maxWidth = 0.2;
priorMeans = [0.6 0.7 0.8];
priorNs = [5 10 100];
[styles, colors, symbols, str] =  plotColors();
for i=1:numel(priorMeans)
  figure; hold on
  for j=1:numel(priorNs)
    priorMean = priorMeans(i);
    priorN = priorNs(j);
    power = powerCurves(priorMean, priorN, nullValue, maxWidth, Ns);
    plot(Ns, power, sprintf('%s%s', styles{j}, colors(j)), 'linewidth', 3);
    legendStr{j}= sprintf('priorN = %d', priorN);
  end
  legend(legendStr ,'location', 'southeast');
  xlabel('N'); ylabel('power')
  title(sprintf('prior mean = %5.3f', priorMean))
  set(gca,'ylim',[0 1]);grid on
  drawnow
end