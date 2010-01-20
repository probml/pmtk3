% logistic regression with RBF basis,  based on Bishop fig 4.12

% Generate some data from a mixture of 3 2d spherical Gaussians
setSeed(0);
mus = [0 0; -1 -1; 1 1];
sigma = 0.05;
N = 100;
pi = normalize(ones(1,3));
X = zeros(N,2);
z = sampleDiscrete(pi,1,N);
labels = z;
labels(labels==3)=2; % merge 2 and 3
colors = 'rbg'; symbols = 'ox*';
figOrig = figure; hold on
for c=1:3
   ndx = find(z==c);
   Nc = length(ndx);
   X(ndx,:) = mvnrnd(mus(c,:), sigma*eye(2), Nc);
   l = labels(ndx(1));
   str = sprintf('%s%s', symbols(l), colors(l));
   plot(X(ndx,1), X(ndx,2), str);
end

% Now map to RBF basis
centres = [-1 -1; 0 0];
sigmaRbf = 1;
for i=1:2
   plot(centres(i,1), centres(i,2), 'k+', 'markersize', 12, 'linewidth', 3);
end
Gtrain = rbfKernel(X, centres, sigmaRbf); % gram matrix
figTransformed = figure; hold on;
for l=1:length(unique(labels))
   ndx = find(labels==l);
   str = sprintf('%s%s', symbols(l), colors(l));
   plot(Gtrain(ndx,1), Gtrain(ndx,2), str);
end
axis_pct

% Fit in transformed space
y = labels; lambda = 0; % 1e-3;
addOnes = true;
w = logregL2Fit(Gtrain,y, lambda, addOnes);

figure(figOrig);
%[x1,x2] = meshgrid(linspace(-1.5,1.5,100), linspace(-1.5,1.5,100));
[x1,x2] = meshgrid(linspace(-2,2,100), linspace(-2,2,100));
[m,n]=size(x1);
Xtest = [reshape(x1, n*m, 1) reshape(x2, n*m, 1)];
Gtest = rbfKernel(Xtest, centres, sigmaRbf);
[yhat, ptest] = logregPredict(Gtest, w, addOnes);
ptest = reshape(ptest, [m n]);
[cc,hh]=contour(x1,x2,ptest,[0.5 0.5], '-k');
set(hh,'linewidth',3);
axis equal
printPmtkFigure('basisFnOriginal')

figure(figTransformed);
G1 = reshape(Gtest(:,1), [m n]);
G2 = reshape(Gtest(:,2), [m n]);
[cc,hh]=contour(G1, G2, ptest,[0.5 0.5], '-k');
set(hh,'linewidth',3);
printPmtkFigure('basisFnTransformed')


