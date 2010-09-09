function precMat = ggmFit(G, X, lambda)
% MLE / MAP for a GGM 
% Lambda is optional strength of a diagonal G-wishart prior

% This file is from pmtk3.googlecode.com

if nargin < 3, lambda = 0; end

if lambda==0
  precMat = ggmFitMinfunc(G, X);
else
  Data.X = X;
  Data.XX = cov(X,1);
  D = size(Data.X,1);
  GWprior.d0 = lambda+2;
  GWprior.S0 = eye(D);
  precMat = GWishartFit(Data, G, GWprior);
end

end
