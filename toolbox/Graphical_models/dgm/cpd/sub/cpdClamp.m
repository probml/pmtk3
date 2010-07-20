function CPD = cpdClamp(CPD, value)
%% Clamp a CPD to a particular value for the child
switch lower(CPD.cpdType)
    
    case 'tabular'

        T         = CPD.T;
        T(:)      = 0;
        ndx       = [repmat({':'}, 1, numel(CPD.sizes)-1), {value}];
        T(ndx{:}) = 1;
        CPD.T     = T;
        
    case 'noisyor'
        
        CPD = cpdClamp(tabularCpdCreate(noisyOrCpd2Cpt(CPD))); 
        
    otherwise
        error('A %s CPD cannot be clamped to a discrete value', CPD.cpdType);
end
end