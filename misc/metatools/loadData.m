function D = loadData(dataset)
%% Load the specified dataset into the struct D, downloading it if necessary
%
%% Example:
%
% D = loadData('prostate');
%%
googleRoot = ' http://pmtkdata.googlecode.com/svn/trunk';
fetcher = which('fetchfile.pl');
%%

dataset = filenames(dataset);

if exist([dataset, '.mat'], 'file') == 2
    D = load([dataset, '.mat']);
else % fetch it
    fprintf('downloading %s, please wait...', dataset);
    source = sprintf('%s/%s/%s.zip', googleRoot, dataset, dataset);
    dest   = fullfile(pmtk3Root(), 'data', [dataset, '.zip']);
    status = perl(fetcher, source, dest);
    if isempty(status)
        fprintf('\n\n');
        error('loadData:fileNotFound', 'The %s data set could not be located', dataset);
    else
        fprintf('done\n');
    end
end
end