function model = linregRobustStudentFitEm( x, y, dof, relTol )
%LINREGROBUSTEMSTUDENTFIT Summary of this function goes here
%   Detailed explanation goes here

if nargin < 4
    relTol = 10^-6;
end

n = length(y);
x = [ones(n,1) x];
w = x\y;
sigma2 = 1/n*sum((y - x*w).^2);
w_diff = inf;
iter = 0;

while w_diff > relTol
    iter = iter+1;
    w_old = w;
    delta = 1/sigma2*(y - x*w).^2;
    s = (dof+1)./(dof+delta);
    x_weighted = diag(s)*x;
    y_weighted = diag(s)*y;
    w = x_weighted\y_weighted;
    sigma2 = 1/(n-1)*sum(s.*(y - x*w).^2);
    w_diff = max(abs(w_old./w-1));
end

model = struct('w', w, 'sigma2', sigma2, 'dof', dof,...
    'relTol', relTol, 'iterations', iter, 'includeOffset', 1);

end
