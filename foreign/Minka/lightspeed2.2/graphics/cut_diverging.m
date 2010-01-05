function c = cut_diverging(x,n)
% CUT_DIVERGING     Index of sign-balanced quantiles
% cut_diverging(x,n) is just like cut_quantile(x,n) except the negative and
% positive numbers are each divided into n/2 quantiles.
% In other words, it cuts x into n parts so that half go to x<0.
%
% Examples:
%   cut_diverging(-2:3,2)
%   cut_diverging(-2:3,3)

n1 = floor(n/2);
n2 = n - n1;
ineg = find(x(:) < 0);
i0 = find(x(:) == 0);
ipos = find(x(:) > 0);
c = zeros(size(x));
c(i0) = n1+1;
c(ineg) = cut_quantile(x(ineg),n1);
c(ipos) = cut_quantile(x(ipos),n2-1)+n1+1;
