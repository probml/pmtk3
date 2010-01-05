function s = makestruct(varargin)
%MAKESTRUCT   Cell-friendly alternative to STRUCT.
% MAKESTRUCT('field1',value1,...) is similar to STRUCT but allows values to
% be specified directly, i.e. cell arrays do not need to be wrapped.
% If a field is specified more than once, the last value is taken.
% You can also use MAKESTRUCT(C) where C is a cell array of fields/values.
% 
% MAKESTRUCT is very useful for parsing argument lists.
% Example:
% function f(varargin)
%   args = makestruct(varargin);
%   default_args = struct('width',4,'height',4);
%   args = setfields(default_args,args);
%
% See also STRUCT.

% Written by Tom Minka
% (c) Microsoft Corporation. All rights reserved.

args = varargin;
if length(args) == 1 && iscell(args{1})
  args = args{1};
end
s = struct;
for i = 1:2:length(args)
  % this is much faster than 'setfield'
  s.(args{i}) = args{i+1};
  %s = setfield(s,args{i},args{i+1});
end
