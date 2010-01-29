
%[X1,X2] = meshgrid(linspace(-5,5,100)',linspace(-5,5,100)');
[X1,X2] = meshgrid(linspace(-2,2,30)',linspace(-2,2,30)');
n = size(X1,1);
X = [X1(:) X2(:)];
C = [1 .4; .4 1]; 
%C = 0.5*eye(2);
df = 0.1;

figure;
p = exp(studentLogpdf(X,[0 0], C,df));
surf(X1,X2,reshape(p,n,n));
title(sprintf('T distribution, dof %3.1f', df))

figure;
logp = studentLogpdf(X,[0 0], C,df);
surf(X1,X2,reshape(logp,n,n));
title(sprintf('log T distribution, dof %3.1f', df))

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
p = exp(gaussLogpdf(X,[0 0],C));
surf(X1,X2,reshape(p,n,n));
title(sprintf('Gaussian'))

figure;
logp = gaussLogpdf(X,[0 0],C);
surf(X1,X2,reshape(logp,n,n));
title(sprintf('log Gaussian'))

placeFigures
