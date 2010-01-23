function model = linregRobustLaplaceLinprog1dFit(x, y)
% minimize the L1 norm of the residuals using linear programming 
% We assume x is an n*1 column vector of scalars
% model.w = [w0 w1], where w0 is the bias

%#author John D'Errico
%#url http://www.mathworks.com/matlabcentral/fileexchange/loadFile.do?objectId=8553&objectType=FILE

n = size(x,1);
f = [0 0 ones(1,2*n)]';
LB = [-inf -inf , zeros(1,2*n)];
UB = [];
Aeq = [ones(n,1), x, eye(n,n), -eye(n,n)];
beq = y;
if isOctave()
    params = linprog(f,zeros(1,length(f)),0,Aeq,beq,LB,UB);
else
    params = linprog(f,[],[],Aeq,beq,LB,UB);
end
w = params(1:2);

model.w   = w;
model.includeOffset = true;
X = [ones(n,1) x(:)];
model.sigma2 = var((X*w - y).^2); % MLE of noise variance
