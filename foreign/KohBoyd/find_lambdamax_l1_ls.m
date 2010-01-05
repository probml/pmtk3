function [lambda_max] = find_lambdamax_l1_ls(At,y)
%
% find_lambdamax_l1_ls returns the maximum value of lambda
%    among all lambdas that make the solution non-zero.
%
% INPUT
%   At  : matrix or object; At = transpose of A
%   y   : vector
%
% [lambda_max] = find_lambdamax_l1_ls(At,y)
%

lambda_max = norm(2*(At*y),inf);
