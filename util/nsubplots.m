function [ynum, xnum] = nsubplots(n)
% Figure out how many plots in the y and x directions to cover n in total
% while keeping the aspect ratio close to rectangular
% but not too stretched

if n==2
  ynum = 2; xnum = 2;
else
  xnum = ceil(sqrt(n));
  ynum = ceil(n/xnum);
end
