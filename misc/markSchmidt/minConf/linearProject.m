function [z] = linearInequalityProject(x,A,b,Aeq,beq,LB,UB)
% Computes Projection of x onto the constraint Ax + b >= 0:
% min_z ||z - x||_2
% s.t. Az + b > 0, Aeqz = Beq, z >= LB, z <= UB

% z'z - 2z'x + x'x

if nargin < 5
    Aeq = [];
    beq = [];
end
if nargin < 6
    LB = [];
end
if nargin < 7
    UB = [];
end

p = length(x);
H = eye(p);
f = -x;

options.LargeScale = 'off';
options.Display = 'none';
z = quadprog(H,f,-A,b,Aeq,beq,LB,UB,x,options);