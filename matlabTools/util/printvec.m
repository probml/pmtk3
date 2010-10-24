function printvec(x, dp)
% Print a vector of numbers to a fixed number of decimal places

% This file is from pmtk3.googlecode.com

if nargin < 2, dp = 3; end
str = sprintf('%s10.%df\n', '%', dp);
for i=1:length(x)
  fprintf(str, x(i))
end
fprintf('\n');
end
