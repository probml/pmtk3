function link = googleCodeLink(fname, displayName, root)
%% Return the html link to fname on the PMTK3 google code repository.
% fname is the full absolute file path

if nargin < 3, root = pmtk3Root(); end

if ~startswith(fname, root)
    fname = which(fname);
end
if ~startswith(fname, root)
    error([ fname ' does not appear to be a PMTK function']);
end
if endswith(root, 'pmtk3')
  googleRoot = 'http://pmtk3.googlecode.com/svn/trunk';
elseif endswith(root, 'pmtksupport')
   googleRoot = 'http://pmtksupport.googlecode.com/svn/trunk';
else
  error(['unrecognized root ' root])
end

link  = [googleRoot, strrep(fname(length(root)+1:end), '\', '/')];
if nargin > 1
    link = sprintf('<a href="%s">%s</a>',link, displayName);
end

end

