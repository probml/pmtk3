function [W, Z]  = fisherLDA(Xtrain, ytrain, K)
% Optimal linear projection from D dimensions to C-1
% Xtrain is N*D, ytrain(i) is in {1,2,...,C}
% W is D*K, where K <= C-1
% Z is the project of Xtrain onto W, i.e. Xtrain*W

C = max(ytrain);
if nargin < 3, K = C-1; end
muC = partitionedMean(Xtrain, ytrain);
Sw = (Xtrain  - muC(ytrain, :))'*(Xtrain  - muC(ytrain, :));
muOverall = mean(Xtrain, 1);
Sb = (ones(C, 1)*muOverall - muC)'*(ones(C, 1)*muOverall - muC);
W = eig(Sw\Sb);
W = W(:, 1:K);
Z = Xtrain*W;
end