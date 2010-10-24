function f = fnameOnly(fullPath, includeExt)
%% Return the filename given its full path
% e.g. fnameOnly('C:\foo\bar\test.m') yields 'test'

% This file is from pmtk3.googlecode.com


if nargin < 2
    includeExt = false;
end
if iscell(fullPath)
    f = cellfuncell(@fnameOnly, fullPath); 
    return;
end
[p, f, ext] = fileparts(fullPath); 
if includeExt
    f = [f, ext];
end
    
end
