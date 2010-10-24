function answer = iscolvec(T)
%% Return true if the result is a column vector

% This file is from pmtk3.googlecode.com


answer = isvector(T) && size(T, 1) > 1;

end
