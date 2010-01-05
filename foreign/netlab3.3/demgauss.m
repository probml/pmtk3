%DEMGAUSS Demonstrate sampling from Gaussian distributions.
%
%	Description
%
%	DEMGAUSS provides a simple illustration of the generation of data
%	from Gaussian distributions. It first samples from a one-dimensional
%	distribution using RANDN, and then plots a normalized histogram
%	estimate of the distribution using HISTP together with the true
%	density calculated using GAUSS.
%
%	DEMGAUSS then demonstrates sampling from a Gaussian distribution in
%	two dimensions. It creates a mean vector and a covariance matrix, and
%	then plots contours of constant density using the function GAUSS. A
%	sample of points drawn from this distribution, obtained using the
%	function GSAMP, is then superimposed on the contours.
%
%	See also
%	GAUSS, GSAMP, HISTP
%

%	Copyright (c) Ian T Nabney (1996-2001)

clc
mean = 2; var = 5; nsamp = 3000;
xmin = -10; xmax = 10; nbins = 30;
disp('Demonstration of sampling from a uni-variate Gaussian with mean')
dstring = [num2str(mean), ' and variance ', num2str(var), '.  ', ...
    num2str(nsamp), ' samples are taken.'];
disp(dstring);
x = mean + sqrt(var)*randn(nsamp, 1);
fh1 = figure;
histp(x, xmin, xmax, nbins);
hold on;
axis([xmin xmax 0 0.2]);
plotvals = linspace(xmin, xmax, 200)';
probs = gauss(mean, var, plotvals);
plot(plotvals, probs, '-r');
xlabel('X')
ylabel('Density')

disp(' ')
disp('Press any key to continue')
pause; 
mu = [3 2];
lam1 = 0.5;
lam2 = 5.0;
Sigma = lam1*[1,1]'*[1,1] + lam2*[1,-1]'*[1,-1];
disp(' ')
disp('Demonstration of sampling from a bi-variate Gaussian.  The mean is')
dstring = ['[', num2str(mu(1)), ', ', num2str(mu(2)), ...
      '] and the covariance matrix is'];
disp(dstring)
disp(Sigma);
ngrid = 40;
cmin = -5; cmax = 10; 
cvals = linspace(cmin, cmax, ngrid);
[X1, X2] = meshgrid(cvals, cvals);
XX = [X1(:), X2(:)];
probs = gauss(mu, Sigma, XX);
probs = reshape(probs, ngrid, ngrid);

fh2 = figure;
contour(X1, X2, probs, 'b');
hold on

nsamp = 300;
dstring = [num2str(nsamp), ' samples are generated.'];
disp('The plot shows the sampled data points with a contour plot of their density.')
samples = gsamp(mu, Sigma, nsamp);
plot(samples(:,1), samples(:,2), 'or');
xlabel('X1')
ylabel('X2')
grid off;

disp(' ')
disp('Press any key to end')
pause; 
close(fh1);
close(fh2);
clear all; 