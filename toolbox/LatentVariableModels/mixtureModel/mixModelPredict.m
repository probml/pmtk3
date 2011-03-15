function [pX] = mixModelPredict(model, X)
% Compute pX(i,v,j) = p(Xj=v|case i), where X(i,:) may be partially
% observed
% This is like mixModelReconstruct expect we compute the posterior
% predictive distribution, intsead of using MAP estimation

% This file is from pmtk3.googlecode.com

if ~strcmpi(model.type, 'discrete')
  error('this function has only been implemented for discrete features')
end

[pZ] = mixModelInferLatent(model, X); % pZ is Ncases*Nnodes
[Ncases Nnodes] = size(pZ);
[Nstates, NobsStates, ndims] = size(model.cpd.T); %#ok
pX = zeros(Ncases, NobsStates, Nnodes);
% p(Xj=v|case i) = sum_k p(Z=k|case i) p(Xj=v | Z=k)
 % = sum_k pZ(i,k) T(k,v,j)

for j=1:Nnodes
  pX(:,:,j) = pZ * model.cpd.T(:,:,j);
end

end
