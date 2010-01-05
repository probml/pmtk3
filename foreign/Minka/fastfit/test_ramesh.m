% plot how the dirichlet fit varies with the input statistics.

ps = linspace(0,.5,100);
as = [];
s = 100;
for i = 1:length(ps)
  p = ps(i);
  bar_p = log([p repmat((1-p)/10,1,10)]);
  d = length(bar_p);
  a = ones(1,d)/d*s;
  a = dirichlet_fit_m([],a,bar_p);
  as(i) = a(1);
end
plot(ps,as/s)
