function logp = dgmLogPrior(dgm)
%% Calculate the logprior of a dgm
CPDs = dgm.CPDs(dgm.CPDpointers);
localCPDs = cellwrap(dgm.localCPDs);
localCPDs = localCPDs(dgm.localCPDpointers); 
allCPDs = [CPDs(:); localCPDs(:)]; 
logp = sum(cellfun(@(cpd)cpd.logPriorFn(cpd), allCPDs)); 
end

