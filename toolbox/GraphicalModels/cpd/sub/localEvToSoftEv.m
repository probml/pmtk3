function softev = localEvToSoftEv(model, localev)
% Convert local evidence to soft evidence
% localev(:,t) is vector of observations for node t
% softev(k,t) is p(st=k| ev(:,t)) using  model.localCPDs{t}
%
% Model can be any model with these fields:
% localCPDs, localCPDpointers
% If model.obsType = 'localev',
%  we just set softev = localev if matrix
%  otherwise we set softev = [1-localev; localev]

% This file is from pmtk3.googlecode.com

[Ndims, Nnodes] = size(localev);

if isfield(model, 'obsType') && strcmpi(model.obsType, 'localev')
  if Ndims==1 % we assume localev=prob(yt=on)
    softev = [1-localev; localev];
  else
    softev = localev; % we assume softev(:,t)
  end
  return;
end


localCPDs = cellwrap(model.localCPDs);
localCPDpointers = model.localCPDpointers;
if numel(localCPDs) == 1
  % if all nodes use the same CPD, we can vectorize
  logB   = mkSoftEvidence(localCPDs{1}, localev);
else
  % each node uses a different CPD
  logB = nan(model.Nstates, Nnodes);
  for t=1:Nnodes
    lev = localev(:, t);
    lev = lev(~isnan(lev));
    if isempty(lev); continue; end
    logB(:, t) = colvec(mkSoftEvidence(localCPDs{localCPDpointers(t)}, lev));
  end
end
softev = exp(logB);

end


