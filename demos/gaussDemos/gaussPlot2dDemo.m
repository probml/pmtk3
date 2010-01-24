function gaussPlot2dDemo()

doSave = 0;
seed = 0; randn('state', seed); rand('state', seed);
mu = [1 0]';        % mean (must be row vector for mvnpdf)
S  = [2 1.5; 1.5 4]    % covariance
%S = randpd(2)*3;
%figure(1); clf
plotSurf(mu, S, 1, 'Full', doSave)

[U,D] = eig(S);      % U = eigenvectors, D= diagonal matrix of eigenvalues.

% Decorrelate
S1 = U'*S*U;
%S1 = diag(diag(S))
plotSurf(mu, S1, 3, 'Diagonal', doSave)

% Compute whitening transform:
A = sqrt(inv(D))*U';
mu2 = A*mu;
S2  = A*S*A'; % might not be numerically equal to I
assert(approxeq(S2, eye(2)))
S2 = eye(2); % to ensure picture is pretty
plotSurf(mu, S2, 5, 'Spherical', doSave)

%%%%%%%%%%%

function plotSurf(mu, S, figndx, ttl, doSave)

[U,D] = eig(S);      % U = eigenvectors, D= diagonal matrix of eigenvalues.

% Evaluate p(x) on a grid.
stepSize = 0.5; % 0.1 is better for contours, 0.1 for surfc
[x,y] = meshgrid(-5:stepSize:5,-5:stepSize:5); % Create grid.
[r,c]=size(x);

% data(k,:) = [x(k) y(k)] for pixel k
data = [x(:) y(:)];
p = mvnpdf(data, mu', S);
p = reshape(p, r, c);

% scale density so it sums to 1 
p=p*stepSize^2;  %  p2(x,y)  defeq  p(x: x+dx, y: y+ dy) approx p(x,y) dx dy
assert(approxeq(sum(p(:)), 1, 1e-1))

figure(figndx);clf
%subplot(3,2,figndx)
surfc(x,y,p);                  % 3D plot
%view(-10,50);
xlabel('x','fontsize',10);
ylabel('y','fontsize',10);
zlabel('p(x,y)','fontsize',10);
rho = S(1,2)/sqrt(S(1,1)*S(2,2));
title(sprintf('%s, S=[%3.1f %3.1f ; %3.1f  %3.1f], %s=%3.2f', ...
	      ttl, S(1,1), S(1,2), S(2,1), S(2,2), '\rho', rho))
  base = 'C:\kmurphy\PML\Figures';
if 0 % doSave
  %fname = fullfile(base, sprintf('gaussPlot2dDemoSurfCoarse%s.eps', ttl))
  %print(gcf, fname, '-depsc');
  fname = fullfile(base, sprintf('gaussPlot2dDemoSurfCoarse%s.jpg', ttl))
  print(gcf, fname, '-djpeg');
end

figure(figndx+1);clf
%subplot(3,2,figndx+1)
contour(x,y,p);           % Plot contours
axis('square');           
xlabel('x','fontsize',10);
ylabel('y','fontsize',10);
% Plot first eigenvector
line([mu(1) mu(1)+sqrt(D(1,1))*U(1,1)],[mu(2) mu(2)+sqrt(D(1,1))*U(2,1)],'linewidth',3)
% Plot second eigenvector
line([mu(1) mu(1)+sqrt(D(2,2))*U(1,2)],[mu(2) mu(2)+sqrt(D(2,2))*U(2,2)],'linewidth',3)

title(sprintf('%s, S=[%3.1f %3.1f ; %3.1f  %3.1f]', ttl, S(1,1), S(1,2), S(2,1), S(2,2)));
if doSave
  %fname = fullfile(base, sprintf('gaussPlot2dDemoContour%s.eps', ttl))
  %print(gcf, fname, '-depsc');
  fname = fullfile(base, sprintf('gaussPlot2dDemoContour%s.jpg', ttl))
  print(gcf, fname, '-djpeg');
end

%figure(10);clf;gaussPlot2d(mu,S);pause
