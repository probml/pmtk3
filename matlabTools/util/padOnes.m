function A = padOnes(data, ndx, sz)
% Pad a vector or matrix with ones
% Returns a vector or matrix with dimensions sz, with ones everywhere
% except at linear indices ndx, where the corresponding entry from data
% is put. 

% This file is from pmtk3.googlecode.com

    if isscalar(sz)
        sz = [sz, 1]; 
    end
    A = ones(sz);
    A(ndx) = colvec(data);
end
