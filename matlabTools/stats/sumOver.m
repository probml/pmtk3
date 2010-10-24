function T = sumOver(T, sum_over)
% Sum multidimensional array T over dimensions 'dims' and squeeze the result
% This is like the built-in sum, but you can pass a vector of dimensions to sum over
% Example
% T = reshape(1:8, [2 2 2])
% sumOver(T, [1 3]) = sum(sum(T,1),3) = [14 22] = [1+2 + 5+6, 3+4 + 7+8]
%  since
%T(:,:,1) =
%     1     3
%     2     4
%T(:,:,2) =
%     5     7
%     6     8

% This file is from pmtk3.googlecode.com


for i=1:numel(sum_over)
    T = sum(T, sum_over(i));
end
T = squeeze(T);



end
