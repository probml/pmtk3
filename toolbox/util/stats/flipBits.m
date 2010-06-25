function yhat = flipBits(y, p)
% Flib bits in binary matrix y with probability p 

M = rand(size(y)) < p;
yhat = y;
yhat(M) = ~yhat(M);

end