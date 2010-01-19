% Plot CI and HPD for beta posterior
N1 = 2; N = 10; a = N1+1; b  = (N-N1)+1; alpha = 0.05;
l = betainv(alpha/2, a, b);
u = betainv(1-alpha/2, a, b);
CI = [l,u] 

figure;
[styles, colors, symbols] = plotColors;
xs = linspace(0, 1, 40);
ps = betapdf(xs, a, b);
plot(xs , ps, 'k-', 'linewidth', 2, 'markersize', 12);
hold on 

HPD = [0.04, 0.485];
ints  = {CI, HPD};
linestyles = {'-', ':'};
for i=1:length(ints)
  l = ints{i}(1); u = ints{i}(2);
  pl = betapdf(l, a, b);
  pu = betapdf(u, a, b);
  h=line([l l], [0 pl]); 
  set(h, 'color', colors(i), 'linestyle', linestyles{i}, 'linewidth', 2);
  h = line([l u], [pl pu]); 
  hh(i)=h; 
  set(h, 'color', colors(i),  'linestyle', linestyles{i},'linewidth', 2);
  h=line([u u], [0 pu]); 
  set(h, 'color', colors(i), 'linestyle', linestyles{i}, 'linewidth', 2);
end

legend(hh, '95% CI', '95% HPD');

printPmtkFigure betaHPD;