% Check that EM with Laplace prior is same as Lasso

% Written by Francois Caron and Kevin Murphy
%% Make some data
setSeed(0);
N=50;
%N=20;
D=50; % dinensionality
rho=.5;
correl=zeros(D,D);
for i=1:D
   for j=1:D
       correl(i,j)=rho^(abs(i-j));
   end
end
X=randn(N,D)*chol(correl);
D_true=3;
% true weight vector has 3 non zero components
z_true=[3 1.5 0 0 2 0 0 0 zeros(1,D-8)]';
sigma = 1;
y=X*z_true+1*sigma*randn(N,1);

%% Now compare methods
model_trial={'laplace','lasso'};
error=zeros(length(model_trial),1);
nb_zeros=zeros(length(model_trial),1);

figure(1);clf
Nmodels = length(model_trial);
subplot(Nmodels+1,1,1)
stem(z_true)
xlim([.5,param.K+.5])
ylim([0 4])
title('TRUE')

for mod=1:length(model_trial)
   param.model=model_trial{mod};
   fprintf('Iterations for model %s\n',param.model)
   param.alpha=1;
   param.c=10;
   param.sigma=-2;
   if strcmp(param.model, 'lasso')
     lambda = 2*sigma^2*sqrt(2*param.c);
     tol = 1e-5;
     quiet = 1;
     z = l1_ls(X, y, lambda, tol, quiet);
   else
     maxIter = 300;
     [z sigma logpdf]=linregSparseEmFit(X, y, param, maxIter);
   end
   params{mod} = z'; % store as row vectors
   %err(mod)=(z-z_true)'*correl*(z-z_true);
   err(mod)=norm(z-z_true);
   %nb_zeros(mod)=sum(abs(z)<10^-10);
   nb_zeros(mod)=sum(abs(z)<10^-3);
   
   subplot(Nmodels+1,1,mod+1)
   stem(z)
   title(sprintf('%s, error %5.3f, num zeros %d', ...
      param.model, err(mod), nb_zeros(mod)))
   xlim([.5,param.K+.5])
   ylim([0 4])
end
