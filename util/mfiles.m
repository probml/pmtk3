function m = mfiles(source, varargin)
% list all mfiles in the specified directory structure.

if nargin == 0, source = pwd(); end
[topOnly, removeExt] = process_options(varargin,'topOnly',false, 'removeExt', false);

if topOnly
    I = what(source);
    m = I.m;
else
    [dirinfo,m] = mfilelist(source);
    m = m';
end
if removeExt
    m = cellfuncell(@(c)c(1:end-2), m);
end

end