function varargout = loadData(dataset, destnRoot, quiet)
%% Load the specified dataset into the struct D, downloading it if necessary
%% from pmtkdata.googlecode.com
%
% If you specify an output, as in D = loadData('foo'), all of the variables
% in the .mat file are stored in the struct D, (unless there is only one).
%
% Otherwise, these variables are loaded directly into the calling
% workspace, just like the built in load() function, as in loadData('foo');
%
%% Examples:
%
% D = loadData('prostate'); % store data in struct D
%
% loadData('prostate');     % load data directly into calling workspace
%
% s = loadData('sat')       % s is a matrix since there is only one variable
%
% s = loadData('sat', 'C:/mydir')
%
%% note
% I only discovered after writing this file, that Matlab's builtin unzip
% function can unzip a file directly from an online url, (also supported
% in Octave). As the current setup is working fine, I haven't changed the
% code, but this may be worth doing in the future.  - Matt July 30, 2010

%%
if nargin < 2, destnRoot = fullfile(pmtk3Root(), 'data'); end
if nargin < 3, quiet = false; end
 
if isOctave(),  warning('off', 'Octave:load-file-in-path'); end
googleRoot = ' http://pmtkdata.googlecode.com/svn/trunk';
%%
dataset = filenames(dataset);
if exist([dataset, '.mat'], 'file') == 2
    D = load([dataset, '.mat']);
else % try and fetch it
    if ~quiet
        fprintf('downloading %s...', dataset);
    end
    source = sprintf('%s/%s/%s.zip', googleRoot, dataset, dataset);
    dest   = fullfile(destnRoot, [dataset, '.zip']);
    ok     = downloadFile(source, dest);
    if ok
        try
            destFolder = fullfile(destnRoot, dataset);
            unzip(dest, fileparts(dest));
            delete(dest);
            addpath(destFolder)
            D = load([dataset, '.mat']);
            if ~quiet
                fprintf('done\n')
            end
        catch %#ok
            fprintf('\n\n');
            error('loadData:postDownloadError', 'The %s data set was found, but could not be loaded', dataset);
        end
    else
        fprintf('\n\n');
        error('loadData:fileNotFound', 'The %s data set could not be located', dataset);
    end
end
if nargout == 0
    names = fieldnames(D);
    for i=1:numel(names)
        assignin('caller', names{i}, D.(names{i}));
    end
else
    if numel(fieldnames(D)) == 1
        names = fieldnames(D);
        varargout{1} = D.(names{1});
    else
        varargout{1} = D;
    end
end
end