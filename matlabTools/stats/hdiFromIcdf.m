function H = hdiFromIcdf(icdf, mass)
% Compute highest density interval from inverse cdf 
% icdf is a function handle
% Find minimum width interval that contains specified mass
% Example:
% HDI for beta(3,9) = [0.04, 0.48]
% a = 3; b= 9; icdf = @(p) betainv(p, a, b); H = hdiFromIcdf(icdf)

% Based on p630 "Doing Bayesian Data Analysis" Kruschke 2010
% See also hdiFromSamples

if nargin < 2, mass = 0.95; end
widthFn = @(lower) icdf(lower+mass)-icdf(lower);
lower = fminbnd(widthFn, 0, 1-mass);
H = [icdf(lower) icdf(lower+mass)];

end
