%% Compare Monte-Carlo and Numerical Integration
% Gelman p95 exercise 3.10.2
data = [6 4 5 5; 60 40 52 48];
S = 10000;
for i=1:size(data, 1)
   H1 = data(i, 1);
   T1 = data(i, 2);
   H2 = data(i, 3); 
   T2 = data(i, 4);
   m1.a = H1+1;
   m1.b = T1+1;
   m2.a = H2+1;
   m2.b = T2+1;
   %% Monte Carlo integration
   p1 = betaSample(m1, S);
   p2 = betaSample(m2, S);
   dif = (p1-p2);
   pgreater = mean(dif > 0);
   display(pgreater); 
   %% numerical integration
   delta = 0.0001;
   theta1 = 0:delta:1;
   pgreaterInt = delta*sum(theta1.^(m1.a-1).*(1-theta1).^(m1.b-1) ...
                .*betainc(theta1, m2.a, m2.b) / beta(m1.a, m1.b));
   display(pgreaterInt);
end
