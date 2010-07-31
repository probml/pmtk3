function link = googleCodeLink(fname, displayName)
%% Return the html link to fname on a PMTK associated google code repository
%
%%
fname = which(fname); 
if nargin < 2
    displayName = fnameOnly(fname); 
end
if startswith(fname, pmtk3Root())
    googleRoot = 'http://pmtk3.googlecode.com/svn/trunk';
    root       = pmtk3Root();
elseif startswith(fname, pmtkSupportRoot())
    googleRoot = 'http://pmtksupport.googlecode.com/svn/trunk';
    root       = pmtkSupportRoot(); 
elseif exist('matlabToolsRoot', 'file') && startswith(fname, matlabToolsRoot())
    googleRoot = 'http://matlabtools.googlecode.com/svn/trunk';
    root       = matlabToolsRoot(); 
else
   link = ''; 
   return; 
end
link  = [googleRoot, strrep(fname(length(root)+1:end), '\', '/')];
link = sprintf('<a href="%s">%s</a>',link, displayName);
end

