function indices = argmax(v)
% Return the index vector of the largest element in the multidim array v
%
% Returns the first maximum in the case of ties.
% Example:
% X = [2 8 4; 7 3 9];
% argmax(X) = [2 3], i.e., row 2 column 3

% This file is from pmtk3.googlecode.com


[m i] = max(v(:));
indices = ind2subv(sizePMTK(v), i);

end
