function CPDs = clampCPDs(CPDs, clamped)
%% Clamp CPDs to the values specified in the sparse vector clamped
% Note, we use this during fitting. For inference, we recommend using
% tabularFactorClamp or tabularFactorSlice, once the CPDs have been
% converted to factors.
for i=find(clamped)
    CPD = CPDs{i};
    T = CPD.T;
    T(:) = 0;
    ndx = [repmat({':'}, 1, 3), {clamped(i)}];
    T(ndx{:}) = 1;
    CPD.T = T;
    CPDs{i} = CPD;
end
end