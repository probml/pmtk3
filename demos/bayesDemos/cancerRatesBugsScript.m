
%PMTKauthor Xuekui Zhang

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%Data set and initial values
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dataStruct= struct('J', 20, ...
    'x', [0, 0, 2, 0, 1, 1, 0, 2, 1, 3, 0, 1, 1, 1, 54, 0, 0, 1, 3, 0], ...
    'n', [1083, 855, 3461, 657, 1208, 1025, 527, 1668, 583, 582, 917, ...
          857, 680, 917, 53637, 874, 395, 581, 588, 383]);
 
 Nchains = 3;
 
% we initialize using strong to vague priors a/b=[10, 1, 0.1]
for i=1:Nchains
  S.theta = sum(dataStruct.x)/sum(dataStruct.n) .* ones(1,dataStruct.J);
  S.a = 10^-(i-2);
  S.b = 10^-(i-2); 
  initStructs(i) = S;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%Call Winbugs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[samples, stats] = matbugs(dataStruct, ...
		fullfile(pwd, 'cancerRatesBugsModel.txt'), ...
		'init', initStructs, ...
		'view', 0, 'nburnin', 5000, 'nsamples', 500, ...
		'thin', 10, ...
		'monitorParams', {'theta', 'a', 'b'}, ...
		'Bugdir', 'C:/Program Files/WinBUGS14');

    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%produce the traceplots
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
N = 20+2; % monitor 22 variables
colors = 'rgb';
figure;
for j=1:12
  subplot(6,2,j); hold on
  for c=1:Nchains
    plot(samples.theta(c,:,j), colors(c));
  end
  title(sprintf('theta %d', j));
end

figure;
for j=1:8
  subplot(5,2,j); hold on
  for c=1:Nchains
    plot(samples.theta(c,:,j+12), colors(c));
  end
  title(sprintf('theta %d', j+12));
end
subplot(5,2,9); hold on
for c=1:Nchains
  plot(samples.a(c,:), colors(c));
end
title(sprintf('a'))
subplot(5,2,10); hold on
for c=1:Nchains
  plot(samples.b(c,:), colors(c));
end
title(sprintf('b'))

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%produce the barplots
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure;
temp = dataStruct.x;
temp(temp>5) = 5;
subplot(4,1,1); hold on
bar(temp);
title(sprintf('number of people with cancer (truncated at 5)'))

temp = dataStruct.n;
temp(temp>2000) = 2000;
subplot(4,1,2); hold on
bar(temp);
title(sprintf('pop of city  (truncated at 2000)'))

subplot(4,1,3); hold on
bar( dataStruct.x ./ dataStruct.n )
h = sum(data.y)/sum(data.n); % pooled MLE
plot([1,20],[h,h], 'linewidth', 2, 'color', 'r')
title(sprintf('MLE, line = pooled MLE'))

subplot(4,1,4); hold on
bar(stats.mean.theta)
title(sprintf('posterior mean, line=E[a/(a + b)|D]'))
h = stats.mean.a / (stats.mean.a + stats.mean.b);
plot([1,20],[h,h], 'linewidth', 2, 'color', 'r')


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%plot the median of thetas with their 95% CIs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Posterior summaries - intervals
figure;
hold on
for j=1:20
  for c=1:Nchains
    q = quantile(samples.theta(c,:,j), [0.025 0.975]);
    h = line([q(1) q(2)], [j j]+c*0.1); set(h, 'color', colors(c));
    q = quantile(samples.theta(c,:,j), [0.5]);
    h=plot(q,j+c*0.1,'*'); set(h, 'color', colors(c));
  end
  legendstr{j} = sprintf('theta %d', j);
end
for i=1:j
  xl = xlim;
  text(xl(2)-0.004, i, legendstr{i});
end
title('95% credible intervals for theta (*=median)')

fprintf('%4.4f ', stats.mean.theta*1000); fprintf('\n')
