function [converged] = convergenceTest(fval, previous_fval, threshold)
% Check if an objective function has converged
%
% We have converged if the slope of the function falls below 'threshold', 
% i.e., |f(t) - f(t-1)| / avg < threshold,
% where avg = (|f(t)| + |f(t-1)|)/2 
% 'threshold' defaults to 1e-4.
% This stopping criterion is from Numerical Recipes in C p423

if nargin < 3, threshold = 1e-4; end

converged = 0;
delta_fval = abs(fval - previous_fval);
avg_fval = (abs(fval) + abs(previous_fval) + eps)/2;
if (delta_fval / avg_fval) < threshold, converged = 1; end
