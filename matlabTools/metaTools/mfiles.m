function m = mfiles(source, varargin)
% List all mfiles in the specified directory structure
%
%% Optional Inputs
% 'topOnly'    - if true, (default = false), do not descend into
%                subdirectories
%
% 'removeExt' - if true, (default = false) remove the '.m' extensions
%
% 'useFullPath'  - if true, (default = false) include the full absolute paths.
%
%% Examples
% mfiles()
% mfiles('C:\pmtk3');
% mfiles('C:\pmtk3', 'topOnly', true);
% mfiles('C:\pmtk3', 'useFullPath', true);
%% See also
% filelist, cfilelist, dirs
%%

% This file is from pmtk3.googlecode.com

if nargin == 0
    source = pwd();
end
[topOnly, removeExt, useFullPath] = process_options(varargin, ...
    'topOnly'      , false ,...
    'removeExt'    , false ,...
    'useFullPath'  , false);
if topOnly
    I = what(source);
    if numel(I) == 0, m = {}; return; end
    m = I.m;
    if useFullPath
        m = cellfuncell(@(c)fullfile(source, c), m);
    end
else
    m = mfilelist(source, useFullPath)';
end
if removeExt
    m = cellfuncell(@(c)c(1:end-2), m);
end
end


function mfiles = mfilelist(directory, useFullPath, mfiles) %#ok<INUSD>
% recursive function, collecting the name of every m-file in the current
% directory and subdirectory.

if(nargin < 3),  mfiles = {}; end %#ok<NASGU>
mf     = dir([directory, filesep(), '*.m']);
mfiles = {mf.name};
if useFullPath
    mfiles = cellfuncell(@(c)fullfile(directory, c), mfiles);
end

flist  = dir(directory);
dlist  =  {flist([flist.isdir]).name};
for i=1:numel(dlist)
    dirname = dlist{i};
    if  ~strcmp(dirname,'.')        && ...
            ~strcmp(dirname,'..')   && ...
            ~isSubstring('.svn', dirname)
        newMfiles = mfilelist...
            (fullfile(directory, dirname), useFullPath, mfiles);
        mfiles = [mfiles, newMfiles]; %#ok<AGROW>
    end
end

end





