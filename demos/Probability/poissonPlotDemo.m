%% Poisson Plot Demo
%
%%
lambdas = [0.1 1 10 20];
figure;
for i=1:4
  subplot(2,2,i)
  xs = 0:25;
  mu = poisspdf(xs, lambdas(i)); % stats toolbox
  h = bar(mu);
  title(sprintf('Poi(%s=%5.3f)', '\lambda', lambdas(i)))
end