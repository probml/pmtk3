function [slope] = getSlope(w,lambda,g,threshold)
% function [slope] = getSlope(w,lambda,g,threshold)
%
% computes the slope used by sub-gradient methods

slope = zeros(size(w,1),1);

% Point zero-valued variables in the right direction
slope(g < -lambda) = g(g < -lambda) + lambda(g < -lambda); 
slope(g > lambda) = g(g > lambda) - lambda(g > lambda);

% Compute the real gradient for zero-valued variables
nonZero = abs(w) > threshold;
slope(nonZero) = g(nonZero) + lambda(nonZero).*sign(w(nonZero));
end