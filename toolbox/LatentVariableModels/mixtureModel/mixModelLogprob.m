function logp = mixModelLogprob(model, X)
%% Calculate logp(i) = log p(X(i,:) | model)
%
%%
[pZ, logp] = mixModelInferLatent(model, X); 
end