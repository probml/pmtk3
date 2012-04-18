% Visualize difference between KL(p,q) and KL(q,p) where p is a mix of two
% 2d Gaussians, and q is a single 2d Gaussian
% This is Figure bishop-5-4

%PMTKauthor Cody Severinski

clear all

mu = [-1,-1; 1,1];

Sigma = zeros(2,2,2);
Sigma(:,:,1) = [1/2,1/4;1/4,1];
Sigma(:,:,2) = [1/2,-1/4;-1/4,1];
SigmaKL = [3,2;2,3];

%x1 = [-10:0.1:10]';
x1 = [-4:0.1:4]';
x2 = x1;

n1 = length(x1);
n2 = length(x2);

f1 = zeros(n1,n2);
f2 = zeros(n1,n2);
klf = zeros(n1,n2);
kll = klf;
klr = klf;

for i=1:n1
  f1(i,:) = mvnpdf([repmat(x1(i),n2,1),x2],mu(1,:),Sigma(:,:,1));
  f2(i,:) = mvnpdf([repmat(x1(i),n2,1),x2],mu(2,:),Sigma(:,:,2));
  klf(i,:) = mvnpdf([repmat(x1(i),n2,1),x2],zeros(1,2),SigmaKL);
  kll(i,:) = mvnpdf([repmat(x1(i),n2,1),x2],mu(1,:),Sigma(:,:,1)*0.6);
  klr(i,:) = mvnpdf([repmat(x1(i),n2,1),x2],mu(2,:),Sigma(:,:,2)*0.6);
end

f = f1 + f2;
% (a)
figure
%contour(x1,x2,f); %,'b',4,'linewidth',3);
h=contour(x1,x2,f,'b'); 
hold on;
%contour(x1,x2,klf); %'r',4,'linewidth',3);
contour(x1,x2,klf, 'r');
hold off;
axis square
axis off
printPmtkFigure('KLfwd')
%print('bishop-5-4a.pdf'); close all;

% (b)
figure
%contour(x1,x2,f); %,'b',4,'linewidth',3);
contour(x1,x2,f,'b');
hold on;
contour(x1,x2,kll, 'r'); %,4,'linewidth',3);
hold off;
axis square
axis off
printPmtkFigure('KLreverse1')
%print('bishop-5-4b.pdf'); close all;

%(c)
figure
contour(x1,x2,f, 'b'); %,4,'linewidth',3);
hold on;
contour(x1,x2,klr, 'r'); %,4,'linewidth',3);
hold off;
axis equal
axis off
printPmtkFigure('KLreverse2')
%print('bishop-5-4c.pdf'); close all;

