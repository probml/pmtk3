
% Reproduce table 1 from "Robust statistical modeling using the T
% distribution", Lange et al, JASA 1989
% The estimated coefficients are similar
% However, this does *not* reproduce the log likelihoods correctly

%#author Hannes Bretschneider

load stackloss;

%% fit model
% dof=0 means estimate from data
% dof=100 means effectively use Gaussian model
dof = [100, 8, 4, 3, 2, 1.1, 1, 0.5, 0];
for i = 1:length(dof)
    modelEM{i} = linregRobustStudentFitEm(X, y, dof(i));
    loglikEM(i) = sum(linregRobustStudentLogprob(modelEM{i}, X, y));
    
    modelConstr{i} = linregRobustStudentFitConstr(X, y, dof(i));
    loglikConstr(i) = sum(linregRobustStudentLogprob(modelConstr{i}, X, y));
end

%% format output

fprintf('estimated dof, EM %5.3f, constr %5.3f\n', ...
  modelEM{end}.dof, modelConstr{end}.dof);
ndof = length(dof);
table = NaN(ndof,6);
table(:,1) = dof';
table(:,2) = loglikEM';
for i = 1:ndof
    table(i,3:6) = modelEM{i}.w;
end
labels = {'dof', 'loglik', 'w0', 'w1', 'w2', 'w3'};
latextable(table, 'Format', '%4.2f', 'horiz', labels, 'hline', 1, ...
  'name', 'stacklossOutputEm');
table


table = NaN(ndof,6);
table(:,1) = dof';
table(:,2) = loglikConstr';
for i = 1:ndof
    table(i,3:6) = modelConstr{i}.w;
end
latextable(table, 'Format', '%4.2f', 'horiz', labels, 'hline', 1, ...
  'name', 'stacklossOutputConstr');
table

