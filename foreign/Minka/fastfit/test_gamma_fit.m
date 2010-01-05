n = 10000;
a = 7.3;
b = 4.5;
x = randgamma(repmat(a,1,n))*b;
[a0,b0] = gamma_fit(x)

% plot the likelihood
m = mean(x);
s = mean(log(x));
as = linspace(1e-1,20,100);
f = (as-1)*s - gammaln(as) - as*log(m) + as.*log(as) - as;
f0 = (a0-1)*s - gammaln(a0) - a0*log(m) + a0.*log(a0) - a0;
df0 = s - digamma(a0) - log(m) + log(a0);
ddf0 = -trigamma(a0) + 1/a0;
c2 = -a0^2*ddf0;
c1 = df0 - c2/a0;
g = c1*as + c2*log(as) - (c1*a0 + c2*log(a0)) + f0;
plot(as,f,'-',as,g,'--')
%plot(as,exp(n*f),'-',as,exp(n*g),'--', a0,exp(n*f0),'o')
axis_pct;
h = (as-1)*s - gammaln(as) - as*log(m) + (1+log(a0))*(as-a0) + a0*log(a0) - as;
hold on, plot(as,h,'r:'), hold off
hold on, plot(a0,f0,'o'), hold off
legend('Exact','Approx','Bound')
set(gcf,'paperpos',[0.25 2.5 4 2])
% print -dpsc gamma_like.ps

t = rand(1,n)*2;
%t = ones(1,n)*2;
x = randnegbin(repmat(a,1,n),b*t);
[a0,b0] = negbin_fit(x,[],t)
