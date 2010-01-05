% RBF transformation for regression in 1d  

setSeed(0);
x = -10:0.1:10;
y = (x<0)*1 + (x>0)*(-1);
N = length(y);
y = y + rand(N,1);

% Now map to RBF basis
centres = [-1 1];
sigmaRbf = 1;
Gtrain = rbfKernel(x, centres, sigmaRbf); % gram matrix
figTransformed = figure; hold on;
for l=1:length(unique(labels))
   ndx = find(labels==l);
   plot(Gtrain(ndx,1), Gtrain(ndx,2), 'ko');
end
axis_pct

% Fit in transformed space
y = labels; lambda = 0; % 1e-3;
w = logregL2Fit(Gtrain,y, lambda);

% Plot decision boundary in original space
figure(figOrig);
[x1,x2] = meshgrid(linspace(-1.5,1.5,100), linspace(-1.5,1.5,100));
[m,n]=size(x1);
Xtest = [reshape(x1, n*m, 1) reshape(x2, n*m, 1)];
Gtest = rbfKernel(Xtest, centres, sigmaRbf);
ptest = logregPredict(Gtest, w);
ptest = reshape(ptest, [m n]);
[cc,hh]=contour(x1,x2,ptest,[0.5 0.5], '-k');
set(hh,'linewidth',3);
axis equal


% Plot decision boundary in original space
figure(figTransformed);
G1 = reshape(Gtest(:,1), [m n]);
G2 = reshape(Gtest(:,2), [m n]);
[cc,hh]=contour(G1, G2, ptest,[0.5 0.5], '-k');
set(hh,'linewidth',3);
printPmtkFigure('basisFnTransformed')



