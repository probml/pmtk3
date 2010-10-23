function yhat = flipBits(y, p)
% Flib bits in binary matrix y with probability p 

% This file is from matlabtools.googlecode.com


M = rand(size(y)) < p;
yhat = y;
yhat(M) = ~yhat(M);

end
