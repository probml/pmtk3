function answer = iscolvec(T)
%% Return true if the result is a column vector

answer = isvector(T) && size(T, 1) > 1;

end