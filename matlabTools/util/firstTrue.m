function idx = firstTrue(boolarray)
% Returns the linear index of the first true element found
% or 0 if none found.

% This file is from pmtk3.googlecode.com



idx = find(boolarray);
if ~isempty(idx);
    idx = idx(1);
else
    idx = 0;
end

end
