a = [3 1 2];
data = dirichlet_sample(a,100);

if 0
  % test initializations for s
  est = [];
  for iter = 1:1000
    data = dirichlet_sample(a,1000);
    m = mean(data);
    bar_p = mean(log(data));
    est(iter,:) = [dirichlet_initial_s(m,bar_p) sum(dirichlet_moment_match(data))];
  end
  hist(est)
  legend('initial s','moment match')
  % dirichlet_initial_s is biased toward small s, but has smaller variance
end

a = dirichlet_fit_s_simple(data,a);

if 0
  % plot objective for variance
  bar_p = mean(log(data));
  m = a/sum(a);
  bar_p = sum(m.*bar_p);
  bar_p = -1.5;
  
  s0 = 1;
  f0 = gammaln(s0) - sum(gammaln(s0*m)) + bar_p*s0;
  g = digamma(s0) - sum(m.*digamma(s0*m)) + bar_p;
  h = trigamma(s0) - sum((m.^2).*trigamma(s0*m));
  
  ss = 0.1:0.1:10;
  f = [];
  for i = 1:length(ss)
    s = ss(i);
    f(i) = gammaln(s) - sum(gammaln(s*m)) + s*bar_p;
    f2(i) = 0.5*h*(s - (s0-g/h))^2 - 0.5*h*(g/h)^2 + f0;
    f3(i) = -s0^2*h*log(s) + (g+s0*h)*s + s0^2*h*log(s0) - (g+s0*h)*s0 + f0;
  end
  figure(1)
  plot(ss, f, ss, f2, ss, f3, s0, f0, 'bo')
  xlabel('x')
  ylabel('f(x)')
  legend('Objective       ', 'Quadratic', 'Proposed',4)
  set(gcf,'PaperPosition', [0.25 2.5 3 3])
  if(s0 < 2)
    axis([0 10 -10 -4])
  end
  return
end

dirichlet_fit_s(data,a)
