function softev = localEvToSoftEvBatch(model, localev)
% Convert local evidence to soft evidence 
% localev(n,t,d) is obs for node t, case n, component d
% softev(k,t,n) is p(node(t)=k | case n) 
%
% This is a batch version of localEvToSoftEv
% that is much faster

% This file is from pmtk3.googlecode.com

[Ncases, Nnodes, Ndims] = size(localev);
Nstates = model.Nstates;
softev = zeros(Nstates, Nnodes, Ncases);

if isfield(model, 'obsType') && strcmpi(model.obsType, 'localev')
  if Ndims==1 % we assume localev=prob(yt=on)
    softev(1,:,:) = 1-localev';
    softev(2,:,:) = localev';
  else
    softev = permute(localev, [3 1 2]); 
  end
  return;
end

if ~isfield(model, 'localMu')
  error('we only support condgauss cpd')
end

for t=1:Nnodes
  for k=1:Nstates
    mu = model.localMu(:,k,t);
    Sigma = model.localSigma(:,:,k,t);
    X = permute(localev(:, t, :), [1 3 2]); % n d  - cases are rows 
    softev(k,t,:)  = reshape(gaussLogprob(mu, Sigma, X), [1 1 Ncases]);
  end
  %softev(:,t,:) = exp(normalizeLogspace(softev(:,t,:)));
  softev(:,t,:) = exp(softev(:,t,:));
end

 
%{
% Debugging - pianfully slow
softev2 = zeros(size(softev));
for n=1:Ncases
  Xn = permute(localev(n,:,:), [2 3 1])'; % d*t
  softev2(:,:,n)  = localEvToSoftEv(model, Xn);
end
assert(approxeq(softev, softev2))
%}

end


