function softev = localEvToSoftEv(model, localev)
% Convert local evidence to soft evidence
% localev(:,t) is vector of observations for node t
% softev(k,t) is p(st=k| ev(:,t)) using  model.localCPDs{t}
%
% Model can be any model with these fields:
% localCPDs, localCPDpointers

% This file is from pmtk3.googlecode.com

[Nstates Nnodes] = size(localev); %#ok
localCPDs = cellwrap(model.localCPDs);
localCPDpointers = model.localCPDpointers;
if numel(localCPDs) == 1 % vectorize
    logB   = mkSoftEvidence(localCPDs{1}, localev);
    softev = exp(logB); 
else
  % each node uses a different CPD
    logB = nan(Nstates, nnodes);
    for t=1:nnodes
        lev = localev(:, t);
        lev = lev(~isnan(lev));
        if isempty(lev); continue; end
        logB(:, t) = colvec(mkSoftEvidence(localCPDs{localCPDpointers(t)}, lev));
    end
    softev = exp(logB); 
end
end
