function [postPred] = binaryFApredictMissing(model, y)
% Compute postPred(n,t) = p(yt=1|y(n,:)), 
% where y(n,t) in {0,1,NaN} where NaN represents missing data

% This file is from pmtk3.googlecode.com

y = canonizeLabels(y) - 1; % ensure {0,1}
[N,T] = size(y);
postPred = zeros(N,T);
W = model.W; b = model.b;
[L p]= size(W);
B = [b(:) W']; % p * (L+1)
muPrior = model.muPrior; SigmaPriorInv = inv(model.SigmaPrior);
for n=1:N
  [muPost, SigmaPost] = varInferLogisticGauss(y(n,:)', W, b, muPrior, SigmaPriorInv);
  mu1 = [1;muPost];
  Sigma1 = zeros(L+1,L+1);
  Sigma1(2:end,2:end) = SigmaPost;
  postPred(n,:) = sigmoidTimesGauss(B, mu1, Sigma1);
  visNdx = ~isnan(y(n,:));
  %postPred(n,visNdx) = y(n, visNdx); % this would restore the noise!
end




