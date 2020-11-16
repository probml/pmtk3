
setSeed(1);

priorVar = 0.01;
n=10;
m=3;

Nobs = m;
D = n+1; % numnber of variables
Nhid = D-Nobs;
xs = linspace(0, 1, D);
perm = randperm(D);
obsNdx = perm(1:Nobs);
hidNdx = setdiff(1:D, obsNdx);


% Noisy observations of the x values at obsNdx
xobs = randn(Nobs, 1);
%obsNoiseVar = 1;
%y = xobs + sqrt(obsNoiseVar)*randn(Nobs, 1);

% Make a (n-1) * (n+1) tridiagonal matrix
L = 0.5*spdiags(ones(n-1,1) * [-1 2 -1], [0 1 2], n-1, n+1);


lambda = 1/priorVar; % precision
L = L*lambda;
L1 = L(:, hidNdx);
L2 = L(:, obsNdx);
B11 = L1'*L1;
B12 = L1'*L2;
B21 = B12';

postDist.mu = -inv(B11)*B12*xobs;
postDist.Sigma = inv(B11);

% Set L=I-A for 1d adjacency martix A 
I = 1:D;
% Right neighbors of each pixel
Icurr = I(1:D-1);
Ineigh = I(2:D);
rows = Icurr(:);
cols = Ineigh(:);
vals = ones((D-1),1);
% Left neighbors of each pixel
Icurr = I(2:D);
Ineigh = I(1:D-1);
rows = [rows;Icurr(:)];
cols = [cols;Ineigh(:)];
vals = [vals;ones((D-1),1)];
% matrix 
A = 1/2*sparse(rows, cols, vals);
L2 = speye(D) - A;

I1=hidNdx;I2=obsNdx;
BB = L'*L;
BB11=BB(I1,I1);BB12=BB(I1,I2);
x2=xobs;
mu = -B11 \ (B12 * x2);
