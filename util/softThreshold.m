
function out = softThreshold(x, delta)
out = sign(x) .* max(abs(x) - delta, 0);
end

