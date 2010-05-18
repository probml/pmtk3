function link = googleCodeLink(fname, displayName)
%% Return the html link to fname on the PMTK3 google code repository.
% fname is the full absolute file path

if ~startswith(fname, pmtk3Root())
    fname = which(fname);
end
if ~startswith(fname, pmtk3Root())
    error('this does not appear to be a PMTK3 function');
end
googleRoot = 'http://pmtk3.googlecode.com/svn/trunk';
link  = [googleRoot, strrep(fname(length(pmtk3Root())+1:end), '\', '/')];
if nargin > 1
    link = sprintf('<a href="%s">%s</a>',link, displayName);
end

end

