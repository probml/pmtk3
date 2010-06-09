function [slope_j] = computeSlope(w,lambda,g,threshold)
% A function that computes the appropriate derivative for non-zero w
% and points zero-valued w's in the right direction
%
% Used by: LassoActiveSet, LassoGrafting, LassoSubGradient
slope_j = zeros(size(w,1),1);

slope_j(g > lambda) = g(g > lambda) + lambda;
slope_j(g < -lambda) = g(g < -lambda) - lambda;
slope_j(abs(w) > threshold) = g(abs(w)>threshold) + lambda*sign(w(abs(w)>threshold));
