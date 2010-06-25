function printvec(x, dp)
% Print a vector of numbers to a fixed number of decimal places
if nargin < 5, dp = 3; end
str = sprintf('%s5.%df\n', '%', dp);
for i=1:length(x)
  fprintf(str, x(i))
end
fprintf('\n');
end