function L = createFactorLookupTable(Tfac)
%% Create a factor lookup table from a cell array of tabular factors
% L(i, j) = 1 iff variable i is in the scope of factor j. 
%%

% This file is from pmtk3.googlecode.com

nfacs    = numel(Tfac);
TFstruct = [Tfac{:}];
nvars    = max([TFstruct.domain]);
L        = zeros(nvars, nfacs);
for f=1:nfacs
    L(Tfac{f}.domain, f) = 1;
end
end
