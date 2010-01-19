function [w] = linregRobustLaplaceLinprogFit(x, y)
% minimize the L1 norm of the residuals using linear programming 
% We assume x is an n*1 column vector of scalars
% w = [w0 w1], where w0 is the bias

%#author John D'Errico
%#url http://www.mathworks.com/matlabcentral/fileexchange/loadFile.do?objectId=8553&objectType=FILE

n = size(x,1);
f = [0 0 ones(1,2*n)]';
LB = [-inf -inf , zeros(1,2*n)];
UB = [];
Aeq = [ones(n,1), x, eye(n,n), -eye(n,n)];
beq = y;
params = linprog(f,[],[],Aeq,beq,LB,UB);
w = params(1:2);
