d = 10;
p = rand(d,1);
ns = ceil(10.^linspace(0,4,20));
for i = 1:length(ns)
  n = ns(i);
  tic
  for iter = 1:10
    x = sample(p,n);
  end
  tim(i) = toc;
end
loglog(ns,tim,'-',ns,tim,'.');
