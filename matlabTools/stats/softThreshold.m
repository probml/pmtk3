function out = softThreshold(x, delta)
% Soft thresholding

% This file is from matlabtools.googlecode.com

out = sign(x) .* max(abs(x) - delta, 0);
end

