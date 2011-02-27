function downloadAllData(destnRoot, quiet)
%% This function downloads all pmtkData from pmtkData.googlecode.com
% By default, it stores data in pmtk3/data, but you can specify a
% diffferent destnRoot. This function does not add the folders to the
% matlab path. If the folders already exist, the contents are overwritten. 
%%

% This file is from pmtk3.googlecode.com

SetDefaultValue(1, 'destnRoot', fullfile(pmtk3Root(), 'data'));
SetDefaultValue(2, 'quiet', false);
googleRoot = ' http://pmtkdata.googlecode.com/svn/trunk';
dataSets = scrapePmtkData();
maxLen = max(cellfun(@numel, dataSets));
for i=1:numel(dataSets)
    dataset = dataSets{i};
    if ~quiet, fprintf('downloading %s%s', dataset, dots(maxLen+3-length(dataset))); end
    source = sprintf('%s/%s/%s.zip', googleRoot, dataset, dataset);
    dest   = fullfile(destnRoot, [dataset, '.zip']);
    ok     = downloadFile(source, dest);
    if ok
        try
            unzip(dest, fileparts(dest));
            delete(dest);
            if ~quiet, fprintf('done\n'); end
        catch %#ok
            if ~quiet, fprintf(2, 'failed\n');  end
        end
    else
        if ~quiet, fprintf(2, 'failed\n');  end
    end
end
end
