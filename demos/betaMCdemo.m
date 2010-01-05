% betaMCdemo


% Gelman p95 exercise 3.10.2
%data = [294  307  288 332];
% pgreater = 0.81


data = [6 4 5 5; 60 40 52 48];
for i=1:size(data,1)
   H1 = data(i,1); T1 = data(i,2); H2 = data(i,3); T2 = data(i,4);
   
   a1 = H1+1; b1 = T1+1;
   a2 = H2+1; b2 = T2+1;
   
   % Monte Carlo integration
   S = 10000;
   p1 = betarnd(a1,b1,S,1);
   p2 = betarnd(a2,b2,S,1);
   dif = (p1-p2);
   pgreater = mean(dif > 0)
   
   % numerical integration
   delta = 0.0001;
   theta1 = 0:delta:1;
   pgreaterInt = delta*sum(theta1 .^ (a1-1) .* (1-theta1) .^ (b1-1) ...
      .* betainc(theta1, a2, b2) / beta(a1, b1))
   
end
