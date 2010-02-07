% robust linear regression on 'stack loss' data
% see Lange et al, "Robus statistical modeling using the T
% distribution", JASA 1989

%#author Hannes Bretschneider

clear Xtrain k n seed x y;
load stackloss;

%% fit model
dof = [100, 8, 4, 3, 2, 1.1, 1, 0.5];
relTol = 10^-10;
for i = 1:length(dof)
    modelEM{i} = linregRobustStudentFitEm(X, y, dof(i), relTol);
    loglikEM(i) = sum(linregRobustStudentLogprob(modelEM{i}, X, y));
    
    modelConstr{i} = linregRobustStudentFitConstr(X, y, dof(i));
    loglikConstr(i) = sum(linregRobustStudentLogprob(modelConstr{i}, X, y));
end

%% format output
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

