% Make something similar to figure 3.5 of Rasmussen and Williams book
% based on demo_laplace_2d from the GPML toolkit
%PMTKauthor Carl Rasmussen
%PMTKmodified Kevin Murphy

% make data
n1=80; n2=40;
S1 = eye(2); S2 = [1 0.95; 0.95 1];
m1 = [0.75; 0]; m2 = [-0.75; 0];                            
randn('seed',17);
x1 = chol(S1)'*randn(2,n1)+repmat(m1,1,n1);
x2 = chol(S2)'*randn(2,n2)+repmat(m2,1,n2);
x = [x1 x2]';
y = [repmat(-1,1,n1) repmat(1,1,n2)]';
[t1 t2] = meshgrid(-4:0.1:4,-4:0.1:4);
t = [t1(:) t2(:)]; % test

% training
loghyper = [0; 0]; % initial guess
learnedloghyper = minimize(loghyper, 'binaryLaplaceGP', -20, 'covSEiso', 'cumGauss', x, y);

% plotting
loghypers = {[log(0.5); log(10)],  learnedloghyper};
for i=1:numel(loghypers)
  loghyper = loghypers{i}
  prob = binaryLaplaceGP(loghyper, 'covSEiso', 'cumGauss', x, y, t);
  figure;
  contour(t1,t2,reshape(prob,size(t1)),[0.1:0.1:0.9]);
  hold on
  contour(t1,t2,reshape(prob,size(t1)),[0.5], 'linewidth', 3, 'color', 'k');
  plot(x1(1,:),x1(2,:),'b+','markersize',12)
  plot(x2(1,:),x2(2,:),'ro','markersize',12)
  str = sprintf('SE kernel, %s=%5.3f, %s=%5.3f', ...
    'l', exp(loghyper(1)), '\sigma^2', exp(loghyper(2)));
  title(str, 'fontsize', 16);
  colorbar
end
