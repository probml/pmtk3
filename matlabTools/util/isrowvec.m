function answer = isrowvec(T)
%% Return true if the result is a row vector

% This file is from pmtk3.googlecode.com


answer = isvector(T) && size(T, 2) > 1;

end
