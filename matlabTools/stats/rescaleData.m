function [y, minx, rangex] = rescaleData(x, minVal, maxVal, minx, rangex)
% Rescale columns to lie in the range minVal:maxVal (defaults to -1:1)

% This file is from pmtk3.googlecode.com


x = double(x);
[n d] = size(x);
if nargin < 2
  minVal = -1; maxVal = 1;
end
if nargin < 4 || isempty(minx)
  minx = min(x,[],1); rangex = drange(x,1);
end
% rescale to 0:1
y = (x-repmat(minx,n,1)) ./ repmat(rangex, n, 1);
% rescale to 0:(max-min)
y = y * (maxVal-minVal);
% shift to min:max
y = y + minVal;

end
