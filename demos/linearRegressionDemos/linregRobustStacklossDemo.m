% Reproduce table 1 from "Robust statistical modeling using the T
% distribution", Lange et al, JASA 1989
% The estimated coefficients are similar
% However, this does *not* reproduce the log likelihoods correctly

load stackloss
% dof=0 means estimate if from data
% dof=100 means (effectively) use a Gaussian
dofs = [100, 8, 4, 3, 2, 0, 1, 0.5];
fprintf('%5s \t %8s \t %8s \t %8s  \t %8s \t %8s \n', ...
  'dof', 'loglik', 'w0', 'w1', 'w2', 'w3');
for i=1:length(dofs)
  model = linregRobustStudentFit(X, y, dofs(i));
  w = model.w;
  ll(i) = sum(linregRobustStudentLogpdf(model, X, y));
  fprintf('%5.3f \t %5.3f \t %5.3f \t %5.3f \t %5.3f \t %5.3f \n', ...
   model.dof, ll(i), w(1), w(2), w(3), w(4));
end

