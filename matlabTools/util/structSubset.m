function S = structSubset(S, fields)
%% Return a struct identical to S except that it has only the specified fields

% This file is from pmtk3.googlecode.com



S = rmfield(S, setdiff(fieldnames(S), fields)); 
S = orderfields(S); 

end
