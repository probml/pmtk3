function f = flops_div
% FLOPS_DIV   Flops for division.
% FLOPS_DIV returns the number of flops needed to divide two scalars.

% This count is based on timing the Pentium 4.
% A better approach would look at an ideal implementation of division
% hardware (Hennessy and Patterson comes to mind) and count how many adders 
% and multipliers are needed.

f = 8;
