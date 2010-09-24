function [W, Z]  = fisherLdaFit(Xtrain, ytrain, K)
% Optimal linear projection from D dimensions to C-1
% Xtrain is N*D, ytrain(i) is in {1,2,...,C}
% W is D*K, where K <= C-1
% Z is the project of Xtrain onto W, i.e. Xtrain*W
%%

% This file is from pmtk3.googlecode.com

C = max(ytrain);

if C==2
  ndx1 = find(ytrain==1); ndx2 = find(ytrain==2);
  m1 = mean(Xtrain(ndx1,:))'; m2 = mean(Xtrain(ndx2,:))';
  S1 = cov(Xtrain(ndx1,:)); S2 = cov(Xtrain(ndx2,:));
  SW = S1+S2;
  W = inv(SW)*(m2-m1);
else
  % this code gives different results to the above if C=2...
  if nargin < 3, K = C-1; end
  muC = partitionedMean(Xtrain, ytrain);
  Sw = (Xtrain  - muC(ytrain, :))'*(Xtrain  - muC(ytrain, :));
  muOverall = mean(Xtrain, 1);
  Sb = (ones(C, 1)*muOverall - muC)'*(ones(C, 1)*muOverall - muC);
  [W, D] = eig(Sw\Sb);
  W = W(:, 1:K);
end
Z = Xtrain*W;
end
