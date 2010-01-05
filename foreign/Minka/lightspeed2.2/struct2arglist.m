function c = struct2arglist(s)
%STRUCT2ARGLIST  Convert structure to cell array of fields/values.
% STRUCT2ARGLIST(S) returns a cell array {'field1',value1,'field2',value2,...}
% It is the opposite of MAKESTRUCT.
%
% Example:
%   function f(varargin)
%   opt.FontSize = 10;
%   opt = setfields(opt,makestruct(varargin),'ignore');
%   varargin = struct2arglist(opt);
%   g(varargin{:});
%
% See also MAKESTRUCT.

% Written by Tom Minka
% (c) Microsoft Corporation. All rights reserved.

f = fieldnames(s);
c = cell(1,2*length(f));
for i = 1:length(f)
  c{2*i-1} = f{i};
  c{2*i} = s.(f{i});
end
