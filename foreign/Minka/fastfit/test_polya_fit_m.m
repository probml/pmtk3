a = [3 1 2]
data = polya_sample(a, rand(1,100)*10);
data = sparse(data);

s = sum(a);
% initialize
m = col_sum(data);
m = m/sum(m);
a = s*m;
polya_fit_m(data,a)
