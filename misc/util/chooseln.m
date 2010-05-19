function c = chooseln(n,k)
% Log of the number of ways of choosing k things from n 
% c = log choose(n,k)

c = factorialln(n) -factorialln (k) - factorialln(n-k);      

end