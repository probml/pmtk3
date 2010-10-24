function Arep = replicate(A, Adims, sz)
%% Replicate A along possibly multiple dimensions so that size(Arep) == sz
%  Adims indicates the dimensions in 1:numel(sz) that A currently contains.
% 
% Replicate is like repmat but only copies where needed to achieve the
% desired size. 
%
%% Example
% In this exmaple, suppose A's dimensions 1:3 map to Arep's dims [2 4 5]
% We want Arep to be of size [4 3 2 4 2]. Notice that if sz = size(Arep)
% then sz(Adims) == size(A)
%%
% A = rand(3, 4, 2); 
% Adims = [2 4 5]; 
% Arep = replicate(A, [2 4 5], [4 3 2 4 2]);
% sz = size(Arep)
% sz =
%     4     3     2     4     2
% assert(isequal(sz(Adims), size(A)));
%%

% This file is from pmtk3.googlecode.com

Arep = bsxTable(@times, onesPMTK(sz), A, 1:numel(sz), Adims); 

end
