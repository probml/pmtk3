function [lambda_max] = find_lambdamax_l1_ls_nonneg(At,y)
%
% find_lambdamax_l1_ls_nonneg returns the maximum value of lambda
%    among all lambdas that make the solution non-zero.
%
% INPUT
%   At  : matrix or object; At = transpose of A
%   y   : vector
%
% [lambda_max] = find_lambdamax_l1_ls_nonneg(At,y)
%

lambda_max = 2*max(At*y);
