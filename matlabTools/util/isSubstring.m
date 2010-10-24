function tf = isSubstring(a, b, ignoreCase)
% Return true iff the first string is a substring of the second

% This file is from pmtk3.googlecode.com

if nargin < 3, ignoreCase = false; end
if ignoreCase
    tf =  ~isempty(strfind(lower(b),lower(a)));
else
    tf = ~isempty(strfind(b,a));
end
end
