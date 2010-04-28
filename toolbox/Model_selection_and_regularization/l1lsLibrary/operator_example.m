% Matlab script for solving the sparse signal recovery problem
% using the object-oriented programming feature of Matlab.
% The three m files in ./@partialDCT/ implement the partial DCT class
% with the multiplication and transpose operators overloaded.

rand('state',0);randn('state',0);   %initialize (for reproducibility)

n = 1024;   % signal dimension
m = 128;    % number of measurements

J = randperm(n); J = J(1:m);    % m randomly chosen indices

% generate the m*n partial DCT matrix whose m rows are 
% the rows of the n*n DCT matrix at the indices specified by J
% see files at @partialDCT/
A  = partialDCT(n,m,J); % A
At = A';                % transpose of A

% spiky signal generation
T  = 10;    % number of spikes
x0 = zeros(n,1);
q  = randperm(n);
x0(q(1:T)) = sign(randn(T,1));

% noisy observations
sigma = 0.01;   % noise standard deviation
y = A*x0 + sigma*randn(m,1);

lambda  = 0.01; % regularization parameter
rel_tol = 0.01; % relative target duality gap

%run the l1-regularized least squares solver
[x,status]=l1_ls(A,At,m,n,y,lambda,rel_tol);

figure(1)
subplot(2,1,1); bar(x0); ylim([-1.1 1.1]); title('original signal x0');
subplot(2,1,2); bar(x);  ylim([-1.1 1.1]); title('reconstructed signal x');
%print -deps fig_operator_example.eps
