%% Compare speed and accuracy of different linregStudent methods
%PMTKauthor Yi Huang
%%


% This file is from pmtk3.googlecode.com

requireOptimToolbox


seed = 0; setSeed(seed);
x = sort(rand(10,1));
y = 1+2*x + rand(size(x))-.5;
% add some outliers
x = [x' 0.1 0.5 0.9]';
k =  -5;
y = [y' k  k k]';

  
NUs = [1:2:9 0];
table = zeros(length(NUs), 7);
for i = 1:length(NUs)
    nu = NUs(i);
    % Using gradient descent
    tic;
    modelGradDesc = linregRobustStudentFitConstr(x, y, nu);
    tGradDesc = toc;
   
    % Using EM
    tic;
    modelEM = linregRobustStudentFitEm(x, y, nu, 'verbose', true);
    tEM = toc;
    table(i,:) = [tGradDesc sqrt(modelGradDesc.sigma2) modelGradDesc.w0 rowvec(modelGradDesc.w) ...
      tEM sqrt(modelEM.sigma2) rowvec(modelEM.w)];
end
table

labels = {'Gtime', 'Gsigma', 'Gw0', 'Gw1', 'EMtime', 'EMsigma', 'EMw0', 'EMw1'};
latextable(table, 'Format', '%5.3f', 'horiz', labels, 'hline', 1, ...
  'name', 'linregStudentTest');
