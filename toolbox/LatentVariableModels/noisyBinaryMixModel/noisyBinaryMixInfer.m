function [pZ] = noisyBinaryMixInfer(model, obs)
% obs is Ncases * Nnodes * Ndims
% so obs(i,j,:) are the observations for node j in case i
%
% Z -> Xj -> Yj, where Y=obs
%
% pZ(i, k) responsibility of cluster k for case i



Nmix   = model.mix.nmix; 
[Ncases Nnodes Ndims] = size(obs); %#ok
logMix = log(rowvec(model.mix.mixWeight)); 
logPz  = zeros(Ncases, nmix); 
for i=1:Ncases
  softev = localEvToSoftEv(model.obsmodel, squeeze(obs(i,:,:))');
  %softev(:,j) with |Xj| rows
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

end

