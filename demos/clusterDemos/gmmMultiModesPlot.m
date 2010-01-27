
% 2d, 2 components

model.mixweights = [0.5;0.5];
model.K = 2;
 % M = desired num. modes
 for M=1:3
   
switch M
  case 3, 
    % 3 modes
    model.mu = [0 0; 1 1]';
    model.Sigma(:,:,1) = [1 0; 0 0.05];
    model.Sigma(:,:,2) = [0.05 0; 0 1];
    xrange = [-3 3 -3 3];
  case 2, 
    model.mu = [-1 -1; 1 1]';
    model.Sigma(:,:,1) = 0.5*eye(2);
    model.Sigma(:,:,2) = 0.5*eye(2);
    xrange = [-3 3 -3 3];
  case 1,
    model.mu = [-0.5 -0.5; 0.5 0.5]';
    model.Sigma(:,:,1) = 0.5*eye(2);
    model.Sigma(:,:,2) = 0.5*eye(2);
    xrange = [-3 3 -3 3];
end


stepsize = 0.1;
[x1,y1] = meshgrid(xrange(1):stepsize:xrange(2), xrange(3):stepsize:xrange(4));
[nrows,ncols] = size(x1);
xx = x1(:); yy = y1(:);
z = exp(gmmLogprob(model, [xx,yy]));
z = reshape(z,nrows,ncols);

figure;
surf(x1, y1, z);
shading interp
view([33, 54])
xlabel('x1'); ylabel('x2');

%plotDistribution(@(X)gmmLogprob(model, X), ...
%  '-useLog', false, '-useContour', false, '-npoints', 500, '-xrange', xrange);

printPmtkFigure(sprintf('gmmMultiModes%d', M))
 end
 
