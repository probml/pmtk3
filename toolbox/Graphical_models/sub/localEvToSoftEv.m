function softev = localEvToSoftEv(model, localev)
%% Convert local evidence to soft evidence

maxNstates = max(model.nstates);
localCPDs = cellwrap(model.localCPDs);
localCPDpointers = model.localCPDpointers;
if numel(localCPDs) == 1 % vectorize
    softev = mkSoftEvidence(localCPDs{1}, localev);
else
    softev = nan(maxNstates, nnodes);
    for t=1:nnodes
        lev = localev(:, t);
        lev = lev(~isnan(lev));
        if isempty(lev); continue; end
        softev(:, t) = colvec(mkSoftEvidence(localCPDs{localCPDpointers(t)}, lev));
    end
end
end