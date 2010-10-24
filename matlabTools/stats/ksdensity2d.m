function [f, gridx1, gridx2] = ksdensity2d(x,gridx1,gridx2,bw)
% KSDENSITY2D Compute kernel density estimate in 2D.
% F = KSDENSITY2D(X,GRIDX,GRIDX2,BW) computes a nonparametric estimate
% of the probability density function of the sample in the N-by-2
% matrix X. F is the vector of density values evaluated at the points
% in the grid defined by the vectors GRIDX1 and GRIDX2. The estimate
% is based on a normal kernel function, using a window parameter
% (bandwidth) that is a function of the number of points in X.
%
% Modified by Kevin Murphy to automatically choose
% gridx1 and gridx2 based on 50 points spanning the range
% (similar to ksdensity)

% This file is from pmtk3.googlecode.com


%PMTKauthor Peter Perkins
%PMTKurl %http://www.mathworks.com/matlabcentral/newsreader/view_thread/125739

if 0
gridx1 = 0:.05:1;
gridx2 = 5:.1:10;
X = [0+.5*rand(20,1) 5+2.5*rand(20,1);
     .75+.25*rand(10,1) 8.75+1.25*rand(10,1)];
figure; plot(X(:,1),X(:,2),'.')
   ksdensity2d(X,gridx1,gridx2);
end

[n,p] = size(x);
npoints = 50;
if nargin < 2
  gridx1 = linspace(min(x(:,1)), max(x(:,1)), npoints);
  gridx2 = linspace(min(x(:,2)), max(x(:,2)), npoints);
end

m1 = length(gridx1);
m2 = length(gridx2);

% Choose bandwidths optimally for Gaussian kernel
if nargin < 4 || isempty(bw)
     sig1 = median(abs(gridx1-median(gridx1))) / 0.6745;
     if sig1 <= 0, sig1 = max(gridx1) - min(gridx1); end
     if sig1 > 0
         bw(1) = sig1 * (1/n)^(1/6);
     else
         bw(1) = 1;
     end
     sig2 = median(abs(gridx2-median(gridx2))) / 0.6745;
     if sig2 <= 0, sig2 = max(gridx2) - min(gridx2); end
     if sig2 > 0
         bw(2) = sig2 * (1/n)^(1/6);
     else
         bw(2) = 1;
     end
end

% Compute the kernel density estimate
[gridx2,gridx1] = meshgrid(gridx2,gridx1);
x1 = repmat(gridx1, [1,1,n]);
x2 = repmat(gridx2, [1,1,n]);
mu1(1,1,:) = x(:,1); mu1 = repmat(mu1,[m1,m2,1]);
mu2(1,1,:) = x(:,2); mu2 = repmat(mu2,[m1,m2,1]);
f = sum(normpdf(x1,mu1,bw(1)) .* normpdf(x2,mu2,bw(2)), 3) / n;

if nargout == 0
% Plot the estimate
% colormap(repmat((256:-1:0)'./256,1,3));
% image(256*f./max(f(:)));
surf(gridx1,gridx2,f);
hold on;
plot3(x(:,1),x(:,2),zeros(n,1),'bo');
hold off;
view(-37.50,30);
end

end
