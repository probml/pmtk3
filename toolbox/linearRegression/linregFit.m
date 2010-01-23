
function model = linregFit(X, y, includeOffset)
% simple linear regression
% Will add a column of 1s and return w=[w0 w1:D] by default
if nargin < 3, includeOffset = true; end
model = linregL2Fit(X, y, 0, includeOffset);
end


