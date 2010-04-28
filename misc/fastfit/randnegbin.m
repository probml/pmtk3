function x = randnegbin(a,b)
% RANDNEGBIN    Generate negative binomial deviates
% Density is p(x) = choose(a+x-1,x) p^x (1-p)^a
% where p = b/(1+b)
% You can incorporate `waiting time' by scaling b.

lambda = randgamma(a).*b;
x = poissrnd(lambda);

end