function b = quantile(x,probs)
% QUANTILE     Quantiles of a data vector.
% quantile(x,probs) behaves like the R function of the same name.
%
% Example:
%   quantile(3:4,[0.3 0.6])

x = sort(x);
x = x(:)';  % workaround matlab indexing bug
pos = probs*(length(x)-1) + 1;
pos_lower = floor(pos);
pos_upper = ceil(pos);
pos_frac = pos - pos_lower;
b = x(pos_lower).*(1-pos_frac) + x(pos_upper).*pos_frac;
