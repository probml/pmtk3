a = [3 1 2];
data = dirichlet_sample(a,100);

% initializer for mean
s = sum(a);
if 1
  % this initializer is best
  m = mean(data);
else
  bar_p = mean(log(data));
  m = exp(bar_p);
  m = m/sum(m);
end
a = s*m;
dirichlet_fit_m(data,a)

