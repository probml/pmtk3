%% Student T Plot Demo
%
%%
%[X1,X2] = meshgrid(linspace(-5,5,100)',linspace(-5,5,100)');

% This file is from pmtk3.googlecode.com

[X1,X2] = meshgrid(linspace(-2,2,30)',linspace(-2,2,30)');
n = size(X1,1);
X = [X1(:) X2(:)];
%C = [1 .4; .4 1]; 
C = 0.5*eye(2);
df = 0.1;

figure;
model.mu = [0 0]; model.Sigma = C; model.dof = df;
p = exp(studentLogprob(model, X));
surf(X1,X2,reshape(p,n,n));
title(sprintf('T distribution, dof %3.1f', df))

figure;
logp = studentLogprob(model, X);
surf(X1,X2,reshape(logp,n,n));
title(sprintf('log T distribution, dof %3.1f', df))
printPmtkFigure('multiT');
if statsToolboxInstalled
  % Matlab converts the covariance matrix to a correlation matrix
   figure;
   p = mvtpdf(X,C,df);
   surf(X1,X2,reshape(p,n,n));
   title(sprintf('matlab T distribution, dof %3.1f', df))
   
   figure;
   logp = log(mvtpdf(X,C,df));
   surf(X1,X2,reshape(logp,n,n));
   title(sprintf('matlab log T distribution, dof %3.1f', df))
end


figure;
p = gaussProb(X, [0 0], C);
surf(X1,X2,reshape(p,n,n));
title(sprintf('Gaussian'))

figure;
model.mu = [0 0];
model.Sigma = C;
logp = gaussLogprob(model, X);
surf(X1,X2,reshape(logp,n,n));
title(sprintf('log Gaussian'))
printPmtkFigure('multiGauss'); 
placeFigures();
