%% Compare Student and Gaussian pdfs

for useLog = [false true]

dofs = [0.1 1 5];
xs = linspace(-4, 4, 40);  
figure;
[styles, colors, symbols] = plotColors;
N = length(dofs);
for i=1:N
    dof = dofs(i);
    ps = tpdf(xs, dof);  
    if useLog
      plot(xs, log(ps), styles{i}, 'linewidth', 2, 'markersize', 12);
    else
      plot(xs, ps, styles{i}, 'linewidth', 2, 'markersize', 12);
    end
    hold on
    legendStr{i} = sprintf('t(%s=%2.1f)', '\nu', dof);
end
ps = normpdf(xs, 0, 1);
if useLog
  plot(xs,  log(ps), styles{N+1}, 'linewidth', 2, 'markersize', 12);
else
  plot(xs, ps, styles{N+1}, 'linewidth', 2, 'markersize', 12);
end
  
legendStr{end+1} = 'N(0,1)';
legend(legendStr)
if(useLog)
  ylabel('log density');
  printPmtkFigure('studentTvsGaussLog'); 
else
  ylabel('density');
  printPmtkFigure('studentTvsGauss'); 
end

end