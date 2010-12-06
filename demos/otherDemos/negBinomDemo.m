% Mixtures of negative binomials
% Demo for Sohrab

function negBinomDemo()

for trial=1:2
N = 100;
theta = 0.5;
xs = 1:N;
probs = [];
for i=1:numel(xs)
  x = xs(i);
  probs(i,1) = binopdf(x,N,theta);
end
names{1} = sprintf('binom(%d,%3.1f)', N,theta);


mu = N*theta;
if trial==1
  thetas = [0.1, 0.5, 0.9];
  % make mode of negbinom match that of binom
  fs = 1 + (1-thetas)./thetas * mu;
else
  thetas = [0.5, 0.5, 0.5, 0.5];
  fs = [1 10 50 90];
end

for k=1:numel(thetas)
  theta=thetas(k);
  f=fs(k);
  names{k+1} = sprintf('negbinom(%5.3f,%5.3f)',f,theta);
  for i=1:numel(xs)
    x = xs(i);
    probs(i,k+1) = exp(negbinomlogpdf(x,f,theta));
  end
end

[styles, colors, symbols, str] =  plotColors; %#ok
figure; hold on
%subplot(2,2,ti); hold on
for j=1:size(probs,2)
  plot(probs(:,j), sprintf('%s', styles{j}), 'color', colors(j), 'linewidth', 3);
end
legend(names)

printPmtkFigure(sprintf('negBinomDemo%d', trial))
end
end


%\NegBinom(s|f,\theta)
% = \binom{s+f-1}{s}
% (1-\theta)^f \theta^s 
 
%\mbox{mean} = f \frac{\theta}{1-\theta},
%\mbox{var} = f \frac{\theta}{(1-\theta)^2}

function p = negbinompdf(s,f,theta)
  p = nchoosek(s+f-1,s)*theta^(s)*(1-theta)^f;
end

function logp = negbinomlogpdf(s,f,theta)
  logp = nchoosekln(s+f-1,s) +s*log(theta) + f*log(1-theta);
end



