function localFacs = dgmEv2LocalFacs(dgm, localev, softev)
%% Handle local and/or soft evidence prior to inference
if ~isempty(localev)
    maxNstates = max(dgm.nstates); 
    localCPDs = cellwrap(dgm.localCPDs); 
    localCPDpointers = dgm.localCPDpointers; 
    if numel(localCPDs) == 1 % vectorize
       B = mkSoftEvidence(localCPDs{1}, localev); 
    else
       B = nan(maxNstates, nnodes);
       for t=1:nnodes
           lev = localev(:, t); 
           lev = lev(~isnan(lev)); 
           if isempty(lev); continue; end
           B(:, t) = colvec(mkSoftEvidence(localCPDs{localCPDpointers(t)}, lev)); 
       end
    end
end
%% Both local and soft evidence
if ~isempty(localev) && ~isempty(softev)
    nanCols = all(isnan(softev), 1);
    softev(:, nanCols) = B(:, nanCols); 
elseif ~isempty(localev)
    softev = B; 
end
%% Convert soft evidence to factors
if ~isempty(softev)
    localFacs = softEvToFactors(softev);
else
    localFacs = {};
end
end