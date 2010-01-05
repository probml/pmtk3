a = [3 1 2];
data = polya_sample(a, repmat(10,1,100));

data = [data zeros(rows(data),1)];

polya_fit_simple(data)
polya_fit(data)
polya_fit_ms(data)
