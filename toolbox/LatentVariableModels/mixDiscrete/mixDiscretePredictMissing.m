function [pX] = mixDiscretePredictMissing(model, X)
% Compute pX(i,j,v) = p(Xj=v|case i), where X(i,:) may be partially
% observed (with NaNs)
% This is like mixModelReconstruct expect we compute the posterior
% predictive distribution, intsead of using MAP estimation

% This file is from pmtk3.googlecode.com


[pZ] = mixDiscreteInferLatent(model, X); % pZ is Ncases*Nnodes
[Ncases Nnodes] = size(pZ); %#ok
[Nstates, NobsStates, ndims] = size(model.cpd.T); %#ok
%pX = zeros(Ncases, NobsStates, Nnodes);


% First make delta functions for observed entries
nStates  = NobsStates*ones(1,ndims);
[~, pX] = dummyEncoding(X, nStates);

% Now replace missing values with predictive distribution
for d=1:ndims
  missing = isnan(X(:,d));
  Nmiss = sum(missing);
  prob = pZ(missing, :) * model.cpd.T(:,:,d); %  p(Xj=v)= sum_k pZ(i,k) T(k,v,j)
  pX(missing, d, :) = reshape(prob, [Nmiss, 1, NobsStates]);
end


end
