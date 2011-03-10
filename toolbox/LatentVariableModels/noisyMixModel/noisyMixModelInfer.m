function [pZ, pX] = noisyBinaryMixInfer(model, Y)
% Y is Ncases * Nnodes * Ndims
% so Y(i,j,:) are the observations for node j in case i
%
% Z -> Xj -> Yj
%
% pZ(i, k) responsibility of cluster k for case i
% pX(i,  c, j) = p(Xj = c | case i) 


Nmix   = model.mixmodel.nmix; 
Nstates = model.Nstates;
[Ncases Nnodes Ndims] = size(Y);
logMix = log(rowvec(model.mixmodel.mixWeight)); 
logPz  = zeros(Ncases, Nmix); 
for i=1:Ncases
  lev = reshape(Y(i,:,:), [Nnodes Ndims]);
  softev = localEvToSoftEv(model.obsmodel, lev');
  %softev(:,j) with |Xj|=Nstates rows
  for k = 1:Nmix
    T = squeeze(model.mixmodel.cpd.T(k,:,:)); % T(c,j), c = state of Xj
    py = sum(T .* softev, 1); % py(j) = sum_c p(yj|xj=c) p(xj=c|z=k)
    ll = sum(log(py + eps));
    logPz(i, k) = logMix(k) + ll;
    %logPz(:, k) = logMix(k) + gaussLogprob(mu(:, k), Sigma(:, :, k), X);
  end
end
[logPz, ll] = normalizeLogspace(logPz);
pZ          = exp(logPz);
if nargout < 2, return; end

pX  = zeros(Ncases, Nstates, Nnodes);
% p(xj=c|y(1:T)) = sum_k p(xj=c, z=k | y(1:T))
%  = sum_k p(xj=c | z=k, y(1:T)) p(z=k | y(1:T))
% = sum_k p(xj=c| z=k, yj) p(z=k | y(1:T))
% = sum_k [p(xj=c | z=k) p(yj | xj=c) / p(yj | z=k)]  p(z=k|y(1:T))
for i=1:Ncases
  lev = reshape(Y(i,:,:), [Nnodes Ndims]);
  softev = localEvToSoftEv(model.obsmodel, lev');
  for k=1:Nmix
    T = squeeze(model.mixmodel.cpd.T(k,:,:)); % T(c,j), c = state of Xj
    localPost = normalize(T .* softev, 1); % T(c,j) * softev(c,j) p(xj=c|k) * p(yj|c) 
     % normalize over c for each j, k
    pX(i, :, :) = pX(i, :, :) + reshape(localPost * pZ(i, k), [1 Nstates Nnodes]);
  end
end
end

