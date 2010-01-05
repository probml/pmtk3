a = [1; 1; 1]*20;

x = [];
for i = 1:1000
  x(:, i) = dirichlet_sample(a);
end
figure(1);
plot(x(1, :), x(2, :), 'o');

figure(2);
hist(x(1, :));

fprintf('        Exact    Empirical\n');

% E[ log p1 ]
[digamma(a(1))-digamma(sum(a)) ...
      sum(log(x(1,:)))/cols(x)]

% E[ p1 log p1 ]
[a(1)/sum(a) * (digamma(a(1)+1) - digamma(sum(a)+1)) ...
      sum(x(1,:) .* log(x(1,:)))/cols(x)]

% E[ 1/p1 ]
[(sum(a)-1)/(a(1)-1) ...
      sum(1./x(1,:))/cols(x)]

b = [5; 2; 3];
y = [];
for i = 1:1000
  y(:, i) = dirichlet_sample(b);
end

% E[ p1/(p1 + q1) ]
a1 = a(1)/sum(a);
b1 = b(1)/sum(b);
[a1/(a1 + b1) ...
sum(x(1,:)./(x(1,:)+y(1,:)))/cols(x)]

% E[ log (p1 + q1) ]
a1 = (a(1)-0.1)/(sum(a)-0.1);
a1 = exp(digamma(a(1)) - digamma(sum(a)));
b1 = (b(1)-0.1)/(sum(b)-0.1);
b1 = exp(digamma(b(1)) - digamma(sum(b)));
[log(a1 + b1) ...
sum(log(x(1,:) + y(1,:)))/cols(x)]
