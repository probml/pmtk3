function refreshZipFiles(dataSource, list)
%% Refreh the contents of the individual zip files in each data folder
% If list is not specified, do this for every data directory.
%
% dataSource is the location of the pmtkData local copy of the svn
% repository.
%
%% Examples
%
% refreshZipFiles()
% refreshZipFiles('C:\pmtkData', 'alarmNetwork')
% refreshZipFiles('C:\pmtkData', {'alarmNetwork', 'anscombe'});
%%

SetDefaultValue(1, 'dataSource', 'C:/kmurphy/GoogleCode/pmtkData'); 


if nargin < 2
    datasets = dirs(dataSource);
else
    datasets = cellwrap(list);
end
%% Check that all of the directories exist
for i=1:numel(datasets)
    assert(exist(fullfile(dataSource, datasets{i}), 'file') == 7);
end
%%
tmproot = fullfile(dataSource, 'tmp');
mkdir(tmproot);
for i=1:numel(datasets)
    d = datasets{i};
    p = fullfile(dataSource, d);
    tmp = fullfile(tmproot, d);
    system(sprintf('svn export %s %s', p, tmp));
    z = fullfile(tmp, [d, '.zip']); 
    if exist(z, 'file')
        delete(z); % remove the old zip file
    end
    zip(fullfile(dataSource, d, [d, '.zip']), tmp);
    system(sprintf('rmdir /Q /S %s', tmp));
end
system(sprintf('rmdir /Q /S %s', tmproot));
end


































