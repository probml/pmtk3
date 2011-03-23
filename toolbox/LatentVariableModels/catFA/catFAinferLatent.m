function [mu, Sigma, loglik] = catFAinferLatent(model, data)
% Infer distribution over latent factors given observed data
% Data format is described in catFAfit
% 
% Output:
% mu(:,n)
% Sigma(:,:,n)
% loglik = (1/N) sum_n log Z(n) 

computeLoglik = (nargout >= 3);

options = struct( 'computeSs', false, 'estimateBeta', false, ...
  'computeLoglik', computeLoglik);
  
if ~isfield(data, 'continuous'); data.continuous = []; end;
if ~isfield(data, 'binary'); data.binary = []; end;
if ~isfield(data, 'categorical'); data.categorical = []; end;

  
missing = any(isnan(data.discrete(:))) || any(isnan(data.binary (:))) || ...
  any(isnan(data.continuous(:)));


data.categorical = encodeDataOneOfM(data.discrete, model.nClass);

% Initialize the variational params randomly
model.params.psi = randn(size(data.categorical));
  

if missing
  [~, loglik, postDist] = inferMixedDataFA_miss(data, model.params, options);
else
   [~, loglik, postDist] = inferMixedDataFA(data, model.params, options);
end

mu = postDist.mean;
if nargout >= 2
  Sigma = postDist.covMat;
end

end

