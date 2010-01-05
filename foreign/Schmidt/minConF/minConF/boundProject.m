function [x] = boundProject(x,LB,UB)
% function [x] = boundProject(x,LB,UB)
%   Computes projection of x onto constraints LB <= x <= UB

x(x < LB) = LB(x < LB);
if nargin > 2
x(x > UB) = UB(x > UB);
end