%% Compare various Normal Inverse Chi Squared Distributions
%
%% gaussInvChi Params

% This file is from pmtk3.googlecode.com

mu = [0 0 0];
k  = [1 5 1];
v  = [1 1 5];
S  = [1 1 1];

%% Convert to gaussInvWishart models for plotting
modelA.mu    = mu(1);
modelA.k     = k(1);
modelA.dof   = v(1);
modelA.Sigma = v(1)*S(1);

modelB.mu    = mu(2);
modelB.k     = k(2);
modelB.dof   = v(2);
modelB.Sigma = v(2)*S(2);

modelC.mu    = mu(3);
modelC.k     = k(3);
modelC.dof   = v(3);
modelC.Sigma = v(3)*S(3);

model = {modelA, modelB, modelC};
%% Plot
rangexy = [-0.9 1 0.1 2];
for m = 1:numel(model);
   fn = @(x)exp(gaussInvWishartLogprob(model{m}, x(:, 1), x(:, 2)));
   figure;
   plotSurface(fn, rangexy);
   hold on;
   plotContour(fn, rangexy);
   set(gca, 'zlim', [0 0.5]); 
   title(sprintf('%s(%s=%g, %s=%g, %s=%g, %s=%g)', 'N\chi^{-2}' , ...
       '\mu_0'      , mu(m) , ...
       '\kappa_0'   , k(m)  , ...
       '\nu_0'      , v(m)  , ...
       '\sigma^2_0' , S(m)  ) ); 
   
   xlabel('\mu');
   ylabel('\sigma^2');
   printPmtkFigure(sprintf('NIX%d', m));
end
