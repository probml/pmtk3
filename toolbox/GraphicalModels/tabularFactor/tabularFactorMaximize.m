function [TF, indices] = tabularFactorMaximize(TF)
%% Set all entries in TF to 0 except for the maximum

% This file is from pmtk3.googlecode.com


[m i] = max(TF.T(:));
TF.T(:) = 0; 
TF.T(i) = m;

if nargout > 1
   indices = ind2subv(size(TF.T), i);  
end


end
