function facs = softEvToFactors(B)
%% Create a tabular factor for each non-nan column of B

nf = size(B, 2); 
facs = cell(nf, 1); 
for i=1:nf
   Bt = B(:, t); 
   if ~any(isnan(Bt))
      facs{i} = tabularFactorCreate(Bt, i);  
   end
end
facs = removeEmpty(facs); 

end