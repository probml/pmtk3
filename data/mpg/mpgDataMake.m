seed = 0; rand('state', seed); randn('state', seed');

data = load('mpg.dat');
N = size(data,1);
perm = randperm(N);
%data = data(perm,:); % remove any possible ordering

x = data(:, 1:7);
y = data(:,8);                  
[n,d] = size(x);
Xtrain = x(1:300,:); ytrain = y(1:300);
Xtest = x(301:end,:); ytest = y(301:end);
save('mpg.mat', 'Xtrain', 'ytrain', 'Xtest', 'ytest');

%    1. cylinders:     multi-valued discrete
%    2. displacement:  continuous
%    3. horsepower:    continuous
%    4. weight:        continuous
%    5. acceleration:  continuous
%    6. model year:    multi-valued discrete
%    7. origin:        multi-valued discrete
%    8. mpg:           continuous

