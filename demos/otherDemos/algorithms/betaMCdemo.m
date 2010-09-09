%% Compare Monte-Carlo and Numerical Integration
% Gelman p95 exercise 3.10.2
%%

% This file is from pmtk3.googlecode.com

function betaMCdemo()
data = [6 4 5 5; 60 40 52 48];
S = 10000;
setSeed(0);
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
    theta1 = betaSample(m1, S);
    theta2 = betaSample(m2, S);
    pgreaterMC = mean(theta1>theta2);
    
    %% numerical integration
    delta = 0.0001;
    theta1 = 0:delta:1;
    pgreaterInt = delta*sum(theta1.^(m1.a-1).*(1-theta1).^(m1.b-1) ...
        .*betainc(theta1, m2.a, m2.b) / beta(m1.a, m1.b));
    
    %% numerical integration 2
    pgreaterInt2 = dblquad(@(t1,t2) integral(t1,t2,m1.a,m1.b,m2.a,m2.b), 0, 1, 0, 1);
    
    fprintf('MC %6.4f, int1 %6.4f, int2 %6.4f\n', ...
        pgreaterMC, pgreaterInt, pgreaterInt2);
end
end

function p = betaProb(t,a,b)
p = t.^(a-1) .* (1-t).^(b-1) ./ beta(a,b);
end

function out = integral(t1,t2,a1,b1,a2,b2)
out = betaProb(t1,a1,b1) .* betaProb(t2,a2,b2) .* (t1 > t2);
end




