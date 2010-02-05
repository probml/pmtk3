% Bayesian T test
% Compare to web program
% http://pcl.missouri.edu/sites/default/bf/one-sample.php

% Paired test
% Data from http://en.wikipedia.org/wiki/Student's_t-test
z = [ 30.02, 29.99, 30.11, 29.97, 30.01, 29.99];
y = [29.89, 29.93, 29.72, 29.98, 30.02, 29.98];
x = y-z;

N = length(x);
t = mean(x)./(std(x)/sqrt(N));
dof = N-1;
sigmaD = 1;
model1.mu = 0; model1.Sigma = 1; model1.dof = dof; 
model2 = model1; model2.Sigma = 1+sigmaD^2*N; 
BF = exp(studentLogprob(model1, t) - studentLogprob(model2, t));

% Sanity check
exponent = -(dof+1)/2;
numer = (1+t^2/dof)^exponent;
denom = (1+N*sigmaD^2)^(-0.5) * (1 + t^2/(dof*(1+N*sigmaD^2)))^exponent;
BF2 = numer/denom
assert(approxeq(BF, BF2))

% Now do unpaired (pooled) test
% Data from Gonen et al 2005 sec 4
xbar = 5; ybar = -0.2727;
Nx = 10; Ny = 11;
sx = 8.7433; sy = 5.9007;

sp = sqrt( ( (Nx-1)*sx^2 + (Ny-1)*sy^2 )/(Nx+Ny-2))
Ndelta = 1/(1/Nx + 1/Ny)
t = (xbar-ybar)/(sp / sqrt(Ndelta))
dof = Nx+Ny-2;
sigmaD = 1/3
model1.mu = 0; model1.Sigma = 1; model1.dof = dof; 
model2 = model1; model2.Sigma =  1+sigmaD^2*Ndelta; 
BF = exp(studentLogprob(model1, t) - studentLogprob(model2, t))

postH0 = 1/(1 + 1/BF)



