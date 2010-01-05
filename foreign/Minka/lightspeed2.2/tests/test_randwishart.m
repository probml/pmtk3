N = 10000;
a = 2.7;
d = 3;
m = zeros(d,d);
m2 = zeros(d,d);
s = 0;
for i = 1:N
  L = randwishart(a,d);
  X = L'*L;
  m = m + X;
  s = s + logdet(X);
  m2 = m2 + X.*X;
end
i = 0:(d-1);
sTrue = sum(digamma(a - i*0.5));
m = m/N;
s = s/N;
v = m2/N - m.*m;
fprintf('Wishart(%g) mean: (should be %g*I)\n', a, a);
disp(m)
fprintf('  E[logdet]: %g (should be %g)\n', s, sTrue);
vTrue = a*(eye(d) + 1)/2;
fprintf('variance:\t\t\t\t\t\t\t\t\ttrue:\n');
disp([v vTrue])
