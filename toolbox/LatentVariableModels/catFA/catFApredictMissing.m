function [predD, predC] = catFApredictMissing(model, discreteData, ctsData)
% discreteData(n, j) in {1..data.nClass(j)}
% ctsData(n, k) in real
% Any location can be NaN, meaning missing value
%
% predD(n,d,k) = p(m(d) = k | n), size Ncases*Nnodes*max(nClass)
% predC(n, d) = E[c(d) | n] 


data.discrete = discreteData';
data.continuous = ctsData';

params = model.params;
nClass = params.nClass;
data.categorical = encodeDataOneOfM(data.discrete, nClass, 'M+1');
data.binary = [];
[pred] = imputeMissingMixedDataFA_ver1(@inferMixedDataFA_miss, data, params, []);
predC = pred.continuous';

if isempty(nClass)
  predD = [];
  return;
end

N = size(pred.categorical,2);
D = numel(nClass);
predD = zeros(N, D, max(nClass));
Md = nClass - 1;
for d = 1:D
  idx = sum(Md(1:d-1))+1:sum(Md(1:d));
  prob_d = pred.categorical(idx,:); % nclass(d)-1 * N
  prob_d = [prob_d; 1-sum(prob_d,1)]; % add back last class
  %pred.discrete(1:nClass(d), d, :) = reshape(prob_d, [nClass(d) 1 N]);
  %pred.discrete = [pred.discrete; prob_d];
  Kd = nClass(d);
  predD(:, d, 1:Kd) = reshape(prob_d', [N 1 Kd]);
end

    

end
