function S = addToStruct(S, varargin)
%% Add variables to a struct using their names in the current scope
% See also structure.m
%
% Caution - this will overwrite any existing fields by the input names. 
% *** does not support anonymous variables as in addToStruct(S, 25, 2+3), etc ***
% 
%%

% This file is from pmtk3.googlecode.com

for i=2:nargin
    S.(inputname(i)) = varargin{i-1};
end
end

