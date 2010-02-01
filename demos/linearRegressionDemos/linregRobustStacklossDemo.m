% This does *not* reproduce the log likelihoods correctly
% The estimated coefficients are similar

load stackloss
dof = 1.1;
modelStudent = linregRobustStudentFit(X, y, dof);
fprintf('estimated dof = %5.3f\n', modelStudent.dof)
fprintf('estimated coef\n'); modelStudent.w(:)'
yhatStudent = linregPredict(modelStudent, X);
N = size(X,1);
X1 = [ones(N,1) X];
mu = X1*modelStudent.w; 
sigma2 = modelStudent.sigma2;
dof = modelStudent.dof;
ll= [];
for i=1:N
  ll(i) = studentLogpdf(studentDist(mu(i), sigma2, dof), y(i));
end
sum(ll)
