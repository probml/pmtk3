function logp = dgmLogPrior(dgm)
%% Calculate the logprior of a dgm
CPDs      = dgm.CPDs; 
%neq       = rowvec(cellfun('length', computeEquivClasses(dgm.CPDpointers))); 
localCPDs = dgm.localCPDs; 
%neqL      = rowvec(cellfun('length', computeEquivClasses(dgm.localCPDpointers))); 

logpLocal = sum(cellfun(@(c)c.logPriorFn(c), localCPDs));
logpCpds  = sum(cellfun(@(c)c.logPriorFn(c), CPDs));
logp      = logpLocal + logpCpds; 


end

