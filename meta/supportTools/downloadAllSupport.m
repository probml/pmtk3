function downloadAllSupport(destnRoot, quiet)
%% Download pmtkSupport packages from pmtkSupport.googlecode.com

SetDefaultValue(1, 'destnRoot', fullfile(pmtk3Root(), 'external'));
SetDefaultValue(2, 'quiet', false);
googleRoot = ' http://pmtksupport.googlecode.com/svn/trunk';
packages = scrapePmtkSupport();
maxLen = max(cellfun(@numel, packages));
for i=1:numel(packages)
    package = packages{i};
    if ~quiet, fprintf('downloading %s%s', package, dots(maxLen+3-length(package))); end
    source = sprintf('%s/%s/%s.zip', googleRoot, package, package);
    dest   = fullfile(destnRoot, [package, '.zip']);
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

addpath(genpathPMTK(destnRoot), '-end');
rootText = ...
{
    'function r = pmtkSupportRoot()';
    '% Return directory name where pmtkSupport is stored';
    '  r = fileparts(which(mfilename()));';
    'end';
};
writeText(rootText, fullfile(destnRoot, 'pmtkSupportRoot.m'));
end