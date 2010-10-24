function indices = argmin(v)
% Return the index vector of the smallest element in the multidim array v
%
% Returns the first minimum in the case of ties.
% Example:
% X = [2 8 4; 7 3 9];
% argmin(X) = [1 1], i.e., row 1 column 1

% This file is from pmtk3.googlecode.com


[m i] = min(v(:)); %#ok
if isvector(v)
  indices = i;
else
  indices = ind2subv(sizePMTK(v), i);
end

end
