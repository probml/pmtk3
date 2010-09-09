function G = constructGraphFromFactors(factors)
%% Construct the graph structure from a cell array of tabularFactors

% This file is from pmtk3.googlecode.com



facStruct = [factors{:}]; 
nvars = max([facStruct.domain]); 

G = zeros(nvars, nvars); 
for i=1:numel(factors)
   dom = factors{i}.domain; 
   G(dom, dom) = 1; 
end
G = setdiag(G, 0); 

end
