function [predD, predC, pred] = catFApredictMissing(model, discreteData, ctsData)
% discreteData(n, j) in {1..data.nClass(j)}
% ctsData(n, k) in real
% Any location can be NaN, meaning missing value
%
% predD(n,d,k) = p(m(d) = k | n), size Ncases*Nnodes*max(nClass)
% predC(n, d) = E[c(d) | n] 
% pred.discrete(dk,n)

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
pred.discrete = [];
for d = 1:D
  idx = sum(Md(1:d-1))+1:sum(Md(1:d));
  prob_d = pred.categorical(idx,:); % nclass(d)-1 * N
  prob_d = [prob_d; 1-sum(prob_d,1)]; % add back last class
  pred.discrete = [pred.discrete; prob_d];
  Kd = nClass(d);
  predD(:, d, 1:Kd) = reshape(prob_d', [N 1 Kd]);
end

% if pred for some category is zero, entropy will be inf. We add eps to avoid
  % this
M = params.nClass;
for d = 1:length(M)
  idx = sum(M(1:d-1))+1:sum(M(1:d));
  p1 = pred.discrete(idx,:);
  if ~isempty(find(sum(p1,2) == 0))
    p1 = p1 + eps;
    p1 = bsxfun(@times, p1, 1./sum(p1));
  end
  pred.discrete(idx,:) = p1;
end


%{
% From Emt's imputeExpt_2
testData.categorical = encodeDataOneOfM(testData.discrete, nClass, 'M+1');
    testData.binary = [];
    [pred, logLik] = imputeMissingMixedDataFA_ver1(@inferMixedDataFA_miss, testData, params, []);
    % pred for discrete (add the sum of probs as last row to predictions)
    pred.discrete = [];
    if ~isempty(nClass)
      Md = nClass - 1;
      for d = 1:length(nClass)
        idx = sum(Md(1:d-1))+1:sum(Md(1:d));
        prob_d = pred.categorical(idx,:);
        prob_d = [prob_d; 1-sum(prob_d,1)];
        pred.discrete = [pred.discrete; prob_d];
      end
    end
  %}  

end
