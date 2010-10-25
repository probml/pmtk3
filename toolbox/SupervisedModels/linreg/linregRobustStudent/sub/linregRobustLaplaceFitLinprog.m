function model = linregRobustLaplaceFitLinprog(X, y)
% Minimize the L1 norm of the residuals using linear programming 
% We assume X is an N*D  matrix, with no column of 1s
% model.w = [w0 w1 ... wD], where w0 is the bias
% PMTKneedsOptimToolbox
% PMTKauthor John D'Errico
% PMTKmodified Kevin Murphy
% PMTKurl http://www.mathworks.com/matlabcentral/fileexchange/loadFile.do?objectId=8553&objectType=FILE

% This file is from pmtk3.googlecode.com


[N,D] = size(X);
D1 = D+1;
f = [zeros(1,D1) ones(1,2*N)]';
LB = [-inf*ones(1,D1) , zeros(1,2*N)];
UB = [];
Aeq = [ones(N,1), X, eye(N,N), -eye(N,N)];
beq = y;
if isOctave()
    w = linprog(f,zeros(1,length(f)),0,Aeq,beq,LB,UB);
else
    w = linprog(f,[],[],Aeq,beq,LB,UB);
end
w  = w(1:D1);
model.w0 = w(1);
model.w   = w(2:end);
model.includeOffset = true;
X1 = [ones(N,1) X];
model.sigma2 = var((X1*w - y).^2); % MLE of noise variance

end
