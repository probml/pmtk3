function logp = dgmLogPrior(dgm)
%% Calculate the logprior of a dgm
CPDs = dgm.CPDs(dgm.CPDpointers);
localCPDs = dgm.localCPDs(dgm.localCPDpointers); 
allCPDs = [CPDs(:); localCPDs(:)]; 
logp = sum(cellfun(@(cpd)cpd.cpdLogPriorFn(cpd), allCPDs)); 
end

