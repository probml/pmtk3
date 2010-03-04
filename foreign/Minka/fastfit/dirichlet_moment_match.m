function a = dirichlet_moment_match(p)
% Each row of p is a multivariate observation on the probability simplex.

a = mean(p);
m2 = mean(p.*p);
ok = (a > 0);
s = (a(ok) - m2(ok)) ./ (m2(ok) - a(ok).^2);
% each dimension of p gives an independent estimate of s, so take the median.
s = median(s);
a = a*s;

end