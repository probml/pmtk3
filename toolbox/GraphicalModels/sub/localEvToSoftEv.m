function softev = localEvToSoftEv(model, localev)
%% Convert local evidence to soft evidence

% This file is from pmtk3.googlecode.com


maxNstates = max(model.nstates);
localCPDs = cellwrap(model.localCPDs);
localCPDpointers = model.localCPDpointers;
if numel(localCPDs) == 1 % vectorize
    logB   = mkSoftEvidence(localCPDs{1}, localev);
    softev = exp(logB); 
else
    logB = nan(maxNstates, nnodes);
    for t=1:nnodes
        lev = localev(:, t);
        lev = lev(~isnan(lev));
        if isempty(lev); continue; end
        logB(:, t) = colvec(mkSoftEvidence(localCPDs{localCPDpointers(t)}, lev));
    end
    softev = exp(logB); 
end
end
