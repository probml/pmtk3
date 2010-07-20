function CPD = tabularCpdClamp(CPD, value)
%% Clamp a tabular CPD to a particular value

T         = CPD.T;
T(:)      = 0;
ndx       = [repmat({':'}, 1, numel(CPD.sizes)-1), {value}];
T(ndx{:}) = 1;
CPD.T     = T;
end