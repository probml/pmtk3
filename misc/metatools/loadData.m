function D = loadData(dataset)
%% Load the specified dataset into the struct D, downloading it if necessary
%
%% Example:
%
% D = loadData('prostate');
%%
googleRoot = ' http://pmtkdata.googlecode.com/svn/trunk';

%%

dataset = filenames(dataset);

if exist([dataset, '.mat'], 'file') == 2
    D = load([dataset, '.mat']);
else % fetch it
    fprintf('downloading %s...', dataset);
    source = sprintf('%s/%s/%s.zip', googleRoot, dataset, dataset);
    dest   = fullfile(pmtk3Root(), 'data', [dataset, '.zip']);
    ok = downloadFile(source, dest);
    destFolder = fullfile(fileparts(dest), dataset);
    unzip(dest, destFolder);
    delete(dest);
    addpath(destFolder)
    D = load([dataset, '.mat']);
    if ok
        fprintf('done\n')
    else
        fprintf('\n\n');
        error('loadData:fileNotFound', 'The %s data set could not be located', dataset);
    end
end
end