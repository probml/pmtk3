function [viol] = computeViol(p,alpha,threshold,gamma,g,bias)
% Computes the violation needed for [Shevade and Keerthi, 2003]
%
% Used by: LassoBlockCoordinate, LassoGaussSeidel

viol = zeros(p,1);
viol(alpha > 0) = abs(gamma + g(alpha > 0));
viol(alpha < 0) = abs(gamma - g(alpha < 0));
if sum(alpha == 0) > 0
viol(alpha == 0) = max(max(-g(alpha==0)-gamma,-gamma+g(alpha==0)),zeros(sum(alpha==0),1));
end
if nargin > 5 && bias == 1
    viol(1) = abs(g(1));
end