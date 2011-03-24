function [mu, Sigma, loglikCases, loglikAvg] = catFAinferLatent(model, discreteData, ctsData, varargin)
% Infer distribution over latent factors given observed data
%
% discreteData(n, j) in {1..data.nClass(j)}
% ctsData(n, k) in real
% Any location can be NaN, meaning missing value
%
%
% Output:
% mu(:,n)
% Sigma(:,:,n)
% loglikCases(n)
% loglikAvg = (1/N) sum_n log Z(n) 

computeLoglik = (nargout >= 3);


% data.foo stores cases in columns, not rows
data.discrete = discreteData';
data.continuous = ctsData';
data.binary = [];


options = struct( 'computeSs', false, 'estimateBeta', false, ...
  'computeLoglik', computeLoglik);
    
missing = any(isnan(data.discrete(:))) || any(isnan(data.binary (:))) || ...
  any(isnan(data.continuous(:)));


data.categorical = encodeDataOneOfM(data.discrete, model.nClass);

% Initialize the variational params randomly
model.params.psi = randn(size(data.categorical));
  

[Dc,Nc] = size(data.continuous);
[Dm,Nm] = size(data.discrete);
[Db,Nb] = size(data.binary);
N = max([Nc,Nm,Nb]);
 

if missing
  [~, loglikAvg, postDist] = inferMixedDataFA_miss(data, model.params, options);
else
  if (Dm+Db)==0 % cts only
    [~, loglikAvg, postDist] = inferFA(data, model.params, options);
  else
    [~, loglikAvg, postDist] = inferMixedDataFA(data, model.params, options);
  end
end

mu = postDist.mean;
if nargout >= 2
  Sigma = postDist.covMat;
end
if ~isempty(loglikAvg)
  loglikCases = loglikAvg*N*ones(1,N); 
end

end

