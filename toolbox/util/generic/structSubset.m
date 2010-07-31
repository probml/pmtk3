function S = structSubset(S, fields)
%% Return a struct identical to S except that it has only the specified fields


S = rmfield(S, setdiff(fieldnames(S), fields)); 
S = orderfields(S); 

end