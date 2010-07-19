function [TF, indices] = tabularFactorMaximize(TF)
%% Set all entries in TF to 0 except for the maximum

[m i] = max(TF.T(:));
TF.T(:) = 0; 
TF.T(i) = m;

if nargout > 1
   indices = ind2sub(i, size(TF.T));  
end


end