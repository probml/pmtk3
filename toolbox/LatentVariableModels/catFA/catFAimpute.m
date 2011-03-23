function pred = catFAimpute(model, testData)
% pred.continuous(d, n) = E[c(d) | n] 
% pred.binary(d,n) = p(b(d) = 1 | n)
% pred.discrete(k,d,n) = p(m(d) = k | n)

params = model.params;
nClass = params.nClass;
testData.categorical = encodeDataOneOfM(testData.discrete, nClass, 'M+1');
testData.binary = [];
[pred] = imputeMissingMixedDataFA_ver1(@inferMixedDataFA_miss, testData, params, []);
% pred for discrete (add the sum of probs as last row to predictions)
%pred.discrete = [];

[Dc,Nc] = size(testData.continuous);
[Dm,Nm] = size(testData.categorical);
N = max([Nc Nm]);
  
pred.discrete = zeros(max(nClass), numel(nClass), N);
if ~isempty(nClass)
  Md = nClass - 1;
  for d = 1:length(nClass)
    idx = sum(Md(1:d-1))+1:sum(Md(1:d));
    prob_d = pred.categorical(idx,:); % nclass(d)-1 * N
    prob_d = [prob_d; 1-sum(prob_d,1)];
    pred.discrete(1:nClass(d), d, :) = reshape(prob_d, [nClass(d) 1 N]);
    %pred.discrete = [pred.discrete; prob_d];
  end
end
    

end
