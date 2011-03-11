function [pZ, pX] = noisyMixModelInferNodes(model, Y, softev)
% Y is Ndims * Nnodes 
% so Y(:,j)  are the observations for node j 
%
% Model is Z -> Xj -> Yj
%
% pZ(k) responsibility of cluster k 
% pX(c, j) = p(Xj = c)


Nmix   = model.mixmodel.nmix;
Nstates  = model.Nstates;
Nnodes = model.Nnodes; 
logMix = log(rowvec(model.mixmodel.mixWeight));
logPz  = zeros(1,Nmix);

if ~isempty(Y)
  softev = localEvToSoftEv(model.obsmodel, Y);
end
%softev(:,j) with |Xj|=Nstates rows
for k = 1:Nmix
  T = squeeze(model.mixmodel.cpd.T(k,:,:)); % T(c,j), c = state of Xj
  py = sum(T .* softev, 1); % py(j) = sum_c p(yj|xj=c) p(xj=c|z=k)
  ll = sum(log(py + eps));
  logPz(k) = logMix(k) + ll;
  %logPz(:, k) = logMix(k) + gaussLogprob(mu(:, k), Sigma(:, :, k), X);
end

[logPz, ll] = normalizeLogspace(logPz);
pZ      = exp(logPz);
if Nmix==1, assert(pZ==1); end % sanity check

if nargout < 2, return; end

pX  = zeros(Nstates, Nnodes);
% p(xj=c|y(1:T)) = sum_k p(xj=c, z=k | y(1:T))
%  = sum_k p(xj=c | z=k, y(1:T)) p(z=k | y(1:T))
% = sum_k p(xj=c| z=k, yj) p(z=k | y(1:T))
% = sum_k [p(xj=c | z=k) p(yj | xj=c) / p(yj | z=k)]  p(z=k|y(1:T))
localPost = zeros(Nstates, Nnodes, Nmix);
for k=1:Nmix
  T = squeeze(model.mixmodel.cpd.T(k,:,:)); % T(c,j), c = state of Xj
  localPost(:,:,k) = normalize(T .* softev, 1); % T(c,j) * softev(c,j) = p(xj=c|k) * p(yj|c)
  % normalize over c for each j, k
end
pX = sum(localPost .* repmat(reshape(pZ, [1 1 Nmix]), [Nstates Nnodes 1]), 3);

  
end

