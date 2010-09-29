function factors = cpds2Factors(CPDs, G, pointers)
%% Convert a cell array of CPDs to tabular factors

% This file is from pmtk3.googlecode.com


if nargin < 3
    pointers = 1:numel(CPDs);
end

nfacs = numel(pointers);
factors = cell(nfacs, 1);
for f=1:nfacs
    cpd = CPDs{pointers(f)};
    switch lower(cpd.cpdType)
        case 'tabular'
            factors{f} = cpt2Factor(cpd.T , G, f);
        case 'noisyor'
            factors{f} = cpt2Factor(noisyOrCpd2Cpt(cpd), G, f); 
        otherwise
            error('%s cannot be converted to a tabular factor');
    end
end




end
