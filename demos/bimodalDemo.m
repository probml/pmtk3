mu = [0 2];
sigma = [1 0.05];
w = [0.5 0.5];
xs = -2:0.01:mu(2)*2;
p = w(1)*normpdf(xs,mu(1),sigma(1)) + w(2)*normpdf(xs,mu(2),sigma(2));
figure;
plot(xs, p,'k-','linewidth',3)
mu = mean(xs .* p);
hold on
h=line([mu mu], [0 max(p)]);
set(h, 'linewidth', 3)
printPmtkFigure('bimodalSpike')
