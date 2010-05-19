function out = softThreshold(x, delta)
% Soft thresholding
out = sign(x) .* max(abs(x) - delta, 0);
end

