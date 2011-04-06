function downloadAllSupport(destnRoot, quiet)
%% Download pmtkSupport packages from pmtkSupport.googlecode.com

% This file is from pmtk3.googlecode.com


SetDefaultValue(1, 'destnRoot', fullfile(pmtk3Root(), 'pmtksupportCopy'));
SetDefaultValue(2, 'quiet', false);
googleRoot = ' http://pmtksupport.googlecode.com/svn/trunk';
%packages = scrapePmtkSupport();
exclude = {'readme.txt', 'pmtkSupportRoot.m', 'meta', 'docs', 'tmp'};
packages = scrapePmtkSupport([], exclude);
maxLen = max(cellfun(@numel, packages));
fprintf('downloading %d packages to pmtk3/pmtksupportCopy from pmtksupport.googlecode.com - this may take a few minutes\n',...
    numel(packages));
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
            if ~quiet, fprintf(2, 'failed to unzip\n');  end
        end
    else
        if ~quiet, fprintf(2, 'failed to download\n');  end
    end
end

addpath(genpath(destnRoot)); % using genpathPMTK here causes problems for Octave
rootText = ...
{
    'function r = pmtkSupportRoot()';
    '% Return directory name where pmtkSupport is stored';
    'w = which(mfilename());';
    'if w(1) == ''.''';
    '  w = fullfile(pwd, w(3:end)); ';
    'end'
    'r = fileparts(w);';
    'end';
};
writeText(rootText, fullfile(destnRoot, 'pmtkSupportRoot.m'));
end
