function dgm = dgmClampCpds(dgm, clamped)
%% clamp unadjustable cpds prior to e.g. learning
% removes precomputed jtree if any

% This file is from pmtk3.googlecode.com


if ~any(clamped)
    return;
end

CPDs = dgm.CPDs;
eqc = computeEquivClasses(dgm.CPDpointers);
for i = 1:numel(CPDs)
    eclass = eqc{i};
    if clamped(eclass(1));
        CPD = CPDs{i};
        val = clamped(eclass(1));
        CPD = cpdClamp(CPD, val);
        CPDs{i} = CPD;
    end
end
dgm.CPDs = CPDs;
if isfield(dgm, 'jtree')
    dgm = rmfield(dgm, 'jtree');
end
if isfield(dgm, 'factors')
    dgm = rmfield(dgm, 'factors');
end
    

end
