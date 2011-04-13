function [probOn, postPred] = binaryFApredictMissing(model, y)
% Compute probOn(n,t) = p(yt=1|y(n,:)), 
% where y(n,t) in {0,1,NaN} where NaN represents missing data
% We also comptue postPred(n,t,:) = [p(0) p(1)]
% to be compatible with other multiclass code

% This file is from pmtk3.googlecode.com

y = canonizeLabels(y) - 1; % ensure {0,1}
[N,T] = size(y);
probOn = zeros(N,T);
postPred = zeros(N,T,2);
W = model.W; b = model.b;
[L p]= size(W);
B = [b(:) W']; % p * (L+1)
muPrior = model.muPrior; SigmaPriorInv = inv(model.SigmaPrior);
for n=1:N
  [muPost, SigmaPost] = varInferLogisticGauss(y(n,:)', W, b, muPrior, SigmaPriorInv, false);
  mu1 = [1;muPost];
  Sigma1 = zeros(L+1,L+1);
  Sigma1(2:end,2:end) = SigmaPost;
  probOn(n,:) = sigmoidTimesGauss(B, mu1, Sigma1);
  visNdx = ~isnan(y(n,:));
  %postPred(n,visNdx) = y(n, visNdx); % this would restore the noise!
end
postPred(:,:,1) = 1-probOn;
postPred(:,:,2) = probOn;

end


