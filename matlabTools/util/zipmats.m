function z = zipmats(varargin)
% Zip up multiple numeric vectors into one cell array
% Takes in an arbitrary number, K, of numeric vectors, v1, v2,...vj,...,vk
% all of the same size, N-by-1, (or 1-by-N) and returns a cell array z,
% such that z{i}(j) = vj(i) for all i in 1:N and all j in 1:K.
%
% Example:
% z = zipmats(1:3 , 4:6 , 7:9 , 100:102)  % extends to any number of inputs
% celldisp(z)
% z{1} =
%      1     4     7   100
% z{2} =
%      2     5     8   101
% z{3} =
%      3     6     9   102

% This file is from pmtk3.googlecode.com


z = mat2cellRows(cell2mat(cellfuncell(@(c)colvec(c), varargin)));  
end
