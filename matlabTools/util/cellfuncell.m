function out = cellfuncell(fun, C, varargin)
% Just like cellfun, except it always returns a cell array
% by setting UniformOutput = false, 
% eg. a=cellfuncell(@(x) upper(x), {'foo','bananas','bar'})
% returns a{1} = 'FOO', etc.

% This file is from pmtk3.googlecode.com


%varargin{end+1} = 'UniformOutput';
%varargin{end+1} = false;  % slow extending varargin unnecessarily
out = cellfun(fun, C, varargin{:},'UniformOutput',false);

end
