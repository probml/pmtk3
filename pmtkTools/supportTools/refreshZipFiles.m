function refreshZipFiles(localSource, refreshList)
%% Refreh the contents of the individual zip files in each data or pmtkSupport folder
% If refreshList is not specified, do this for every data or pmtkSupport directory.
%
%% Inputs
% localSource - this is the full path to the local copy of the pmtkData or
%               pmtkSupport svn repository, OR, the name
%               'support', or 'data' in which case the appropriate path is
%               obtained from config.txt or config-local.txt.
%
% refreshList - this is a cell array of directory names to be refreshed or
%               a single string indicating one such directory. If this is
%               not specified, all directories are updated.
%% Examples
%
% refreshZipFiles() % default is pmtkData
% refreshZipFiles('data', 'alarmNetwork')
% refreshZipFiles('C:\googleCode\pmtkData', {'alarmNetwork', 'anscombe'});
%
% refreshZipFiles('support', 'fastfit')
% 
%% Notes
% The directories must be part of the svn repository as we use the svn
% export command.
% PMTKneedsMatlab
%%

% This file is from pmtk3.googlecode.com

excludedDirs = tokenize(getConfigValue('PMTKmetaDirs'), ',')'; % don't zip these up!
%%
SetDefaultValue(1, 'localSource', getConfigValue('PMTKlocalDataPath'));
switch localSource
    case 'support'
        localSource = getConfigValue('PMTKlocalSupportPath');
    case 'data'
        localSource = getConfigValue('PMTKlocalDataPath');
end
if nargin < 2
    tozip = dirs(localSource);
else
    tozip = cellwrap(refreshList);
end
tozip = setdiff(tozip, excludedDirs); 
%% Check that all of the directories exist
for i=1:numel(tozip)
  dname = fullfile(localSource, tozip{i});
   if exist(dname, 'dir') ~= 7
     error(sprintf('directory %s does not exist', dname))
   end
end
%%
tmproot = fullfile(localSource, 'tmp');
%tmproot = tempdir;
mkdir(tmproot);
maxLen = max(cellfun(@length, tozip)); 
for i=1:numel(tozip)
    z = tozip{i};
    fprintf('processing %s%s', z, dots(maxLen - length(z)+3)); 
    p = fullfile(localSource, z);
    tmp = fullfile(tmproot, z);
    system(sprintf('svn export %s %s', p, tmp));
    destZip = fullfile(localSource, z, [z, '.zip']);
    if exist(destZip, 'file')
        delete(destZip); % remove the old zip file
    end
    zip(destZip, tmp);
    if ispc
        system(sprintf('rmdir /Q /S %s', tmp));
    else
        system(sprintf('rm -rf %s', tmp));
    end
    %[success,message,messageid]  = rmdir(tmp);
end
if ispc
    system(sprintf('rmdir /Q /S %s', tmproot));
else
    if exist(tmproot, 'dir')
        %rmdir(tmproot);
        system(sprintf('rm -rf %s', tmproot));
    end
end

end
