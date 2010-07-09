function answer = isrowvec(T)
%% Return true if the result is a row vector

answer = isvector(T) && size(T, 2) > 1;

end