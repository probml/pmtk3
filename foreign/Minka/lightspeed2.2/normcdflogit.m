function e = normcdflogit(x)
% NORMCDFLOGIT   log(normcdf/(1-normcdf))
% More accurate than explicitly evaluating log(normcdf/(1-normcdf)), and
% retains more precision than normcdfln when x is large.

% Written by Tom Minka
% (c) Microsoft Corporation. All rights reserved.

e = x;
small = -7;
large = 7;
i = find(x >= small & x <= large);
if ~isempty(i)
  e(i) = normcdf(x(i));
  e(i) = log(e(i)./(1-e(i)));
end
i = find(x < small);
if ~isempty(i)
  e(i) = normcdfln(x(i));
  %e(i) = e(i) - log(1-exp(e(i)));
end
i = find(x > large);
if ~isempty(i)
  e(i) = -normcdfln(-x(i));
  %e(i) = log(1-exp(-e(i))) + e(i);
end
