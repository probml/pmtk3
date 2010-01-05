function [density,test] = hhist(data, resolution)
% HHIST       Locally-adaptive unbiased density estimate.
%
% hhist(data) plots a density estimate of p(data).
% hhist(data,resolution) increases the resolution of the plotted curve.
% density = hhist(data,resolution) returns the density estimate instead of 
% plotting it.  length(density) == resolution.
% [density,test] = hhist(data,resolution) also returns the locations at which
% the density was evaluated.
%
% The algorithm is linear interpolation of the empirical cumulative 
% distribution.  Reference:
% Bruce M. Hill, "Posterior Distribution of Percentiles: Bayes'
% Theorem for Sampling from a Population", Journal of the American
% Statistical Association, Vol. 63, No. 322. (Jun., 1968),
% pp. 677-691.
% http://links.jstor.org/sici?sici=0162-1459%28196806%2963%3A322%3C677%3APDOPBT%3E2.0.CO%3B2-O
%
% See test_hhist.m for a demonstration.

% Written by Tom Minka

n = length(data);
data = data(:);
data = sort(data);
% find the number of occurrences of each point.
% keep only the first two occurrences, and remember the total count.
d = [0; data(1:end-1)==data(2:end)];
dd = diff([d; 0]);
dd2 = [0; dd(1:end-1)];
firstdup = (dd > 0);
seconddup = (dd2 > 0);
lastdup = (dd < 0);
nodup = (dd == 0 & d == 0);
% set the second occurrence to be the next larger double-precision number.
data(seconddup) = data(seconddup) + eps(data(seconddup));
dstart = find(firstdup | seconddup | nodup);
dend = find(firstdup | lastdup | nodup);
data = data(dstart);
% count(i) is the number of occurrences of data(i)
count = dend-dstart+1;

if nargin < 2
  resolution = 1000;
end
delta = 0.05*range(data);
if delta == 0
  delta = 1;
end
mind = min(data)-delta;
maxd = max(data)+delta;
if length(resolution) == 1
  test = linspace(mind,maxd,resolution);
else
  test = resolution;
  mind = min(mind, min(test));
  maxd = max(maxd, max(test));
end

% A tricky aspect of this algorithm is that it is not enough to simply 
% evaluate the density at the test locations.  If you do that, you may miss
% sharp spikes.  Instead, you must compute the average density around each
% test location.

if 0
% Algorithm to evaluate the density at test locations only: 
% 1. Compute the slope of the cdf between consecutive input points.
%    For the last point, the slope is zero.
% 2. For each test location, find the nearest input point which is smaller.
%    This is cleverly done via the interp1 function.
% 3. Use the previously computed slope as the density at that test location.

% g(i) = slope of the cdf between data(i) and data(i+1)
g = [0; 1./diff(data); 0; 0];
% extend data so that interp1 doesn't fail
% note mind < min(data), maxd > max(data)
datax = [mind; data; maxd];
index = [0; cumsum(count); 0];
test_index = floor(interp1(datax,index,test));
density = g(test_index)/(length(data)+1);
end

% Algorithm to compute the average density around each test location:
% 1. Find the borders of the nearest-neighbor cell for each test location.
% 2. Evaluate the cdf at the border locations.
% 3. Use the cdf slope between borders as the density for the test location.
test = test(:);
border = [mind; (test(1:end-1) + test(2:end))/2; maxd];
% extend data so that interp1 doesn't fail
% note mind < min(data), maxd > max(data)
datax = [mind; data; maxd];
index = [0; cumsum(count); 0];
border_cdf = interp1(datax,index,border);
% this prevents the estimate from extending beyond the data limits.
border_cdf(border<min(data)) = 1;
border_cdf(border>max(data)) = n;
plot(border,border_cdf)
density = diff(border_cdf)./diff(border)/(n-1);

if nargout == 0
  plot(test, density)
  axis_pct
  clear density
end
