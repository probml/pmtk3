%
%   simple example to show the usage of l1_ls
%

% problem data
A  = [1    0    0   0.5;...\
      0    1  0.2   0.3;...\
      0  0.1    1   0.2];
x0 = [1 0 1 0]';    % original signal
y  = A*x0;          % measurements with no noise
lambda = 0.01;      % regularization parameter
rel_tol = 0.01;     % relative target duality gap

[x,status]=l1_ls(A,y,lambda,rel_tol);
