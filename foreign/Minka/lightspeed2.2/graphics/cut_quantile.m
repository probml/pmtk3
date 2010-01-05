function [c,b] = cut_quantile(x,n)
% CUT_QUANTILE   Index of quantiles.
% cut_quantile(x,n) returns a matrix of quantile numbers, same size as x, 
% ranging 1..n (n is the desired number of quantiles).  
% The values with number 1 are in the first quantile, etc.
% [c,b] = quantile(x,n) returns the quantile values selected
%
% Example:
%   cut_quantile(1:10,4)

probs = linspace(0,1,n+1);
b = quantile(unique(x(:)),probs);

c = zeros(size(x));
for b_iter = 1:(length(b)-1)
  c(x >= b(b_iter)) = b_iter;
end
