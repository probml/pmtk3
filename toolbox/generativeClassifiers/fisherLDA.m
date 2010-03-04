function [W, Z]  = fisherLDA(Xtrain, ytrain, K)
% Optimal linear projection from D dimensions to C-1
% Xtrain is N*D, ytrain(i) is in {1,2,...,C}
% W is D*K, where K <= C-1

D = size(Xtrain,2);
C = max(ytrain);
if nargin < 3, K = C-1; end
muC = zeros(C,D);
for c=1:C
  muC(c,:) = mean(Xtrain(ytrain==c,:),1);
end

Sw = (Xtrain  - muC(ytrain,:))'*(Xtrain  - muC(ytrain,:));
muOverall = mean(Xtrain, 1);
Sb = (ones(C,1)*muOverall-muC)'*(ones(C,1)*muOverall-muC);
[W,D] = eig(inv(Sw)*Sb);
W = W(:, 1:K);
Z = Xtrain*W;

end