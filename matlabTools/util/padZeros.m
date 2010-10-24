function A = padZeros(data, ndx, sz)
% Pad a vector or matrix with zeros
% Returns a vector or matrix with dimensions sz, with zeros everywhere
% except at linear indices ndx, where the corresponding entry from data
% is put. 

% This file is from pmtk3.googlecode.com

    if isscalar(sz)
        sz = [sz, 1]; 
    end
    A = zeros(sz);
    A(ndx) = colvec(data);
end
