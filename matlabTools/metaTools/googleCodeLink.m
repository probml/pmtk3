function link = googleCodeLink(fname, displayName, type)
%% Return the html link to fname on a PMTK associated google code repository
%
%%

% This file is from pmtk3.googlecode.com

if nargin < 3
    type = 'html';
end

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
switch type
    case 'html'
        link = sprintf('<a href="%s">%s.m</a>',link, displayName);
    case 'publish'
        link = sprintf('<%s %s>',link, displayName);
    case 'wiki'
        link = sprintf('[%s %s]',link, displayName);
end

