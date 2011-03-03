function gamma = tfMarg2Mat(facs)
%% Convert a cell array of marginal tabular factors to a single matrix 
% of size max(nstates)-by-nMarginals

% This file is from pmtk3.googlecode.com


nMarginals = numel(facs); 
maxNstates = max(cellfun(@(f)f.sizes, facs)); 
gamma = NaN(maxNstates, nMarginals); 
for i=1:nMarginals
   T = facs{i}.T; 
   gamma(1:length(T), i) = T; 
end


end
