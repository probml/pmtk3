function facs = softEvToFactors(B)
%% Create a tabular factor for each column of B
% with nstates equal to the number of non-nan elements in the column
% Factors are annotated 1:size(B, 2)

nf = size(B, 2); 
facs = cell(nf, 1); 
for i=1:nf
   Bt = B(:, i); 
   if all(isnan(Bt)), continue; end
   facs{i} = tabularFactorCreate(Bt(~isnan(Bt)), i);  
end
facs = removeEmpty(facs); 

end