function H = hdiFromSamples(samples, mass)
% Compute 1 highest density interval from bag of samples
% Based on p628 "Doing Bayesian Data Analysis" Kruschke 2010
% Example: 95% HDI for beta(3,9) is [0.045, 0.49]
% setSeed(0); a= 3; b = 9; hdiFromSamples(betarnd(a,b,1,10000));
% See also hdiFromIcdf

if nargin < 2, mass = 0.95; end

N  = numel(samples);
sortedPoints = sort(samples);
inc = floor(mass * N);
nCIs = N-inc;
ciWidth = zeros(1,nCIs);
for i=1:nCIs
  ciWidth(i) = sortedPoints(i+inc) - sortedPoints(i);
end
narrowest = argmin(ciWidth);
HDImin = sortedPoints(narrowest);
HDImax = sortedPoints(narrowest+inc);
H = [HDImin HDImax];

end
