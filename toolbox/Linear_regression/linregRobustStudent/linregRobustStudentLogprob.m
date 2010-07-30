function ll = linregRobustStudentLogprob(model, X, y)
% ll(i) = log p(y(i)|X(i,:), model)

N = size(X,1);
mu = linregPredict(model, X);
sigma2 = model.sigma2;
dof = model.dof;
ll = zeros(1,N);
for i=1:N
  [ll(i)] = studentLogprob(studentCreate(mu(i), sigma2, dof), y(i));
end

end