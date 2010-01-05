a = 3.75;
x = randgamma(repmat(a,1,10000));

% E[x]
mean(x)
a

% E[log(x)]
mean(log(x))
digamma(a)
