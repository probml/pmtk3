function downloadAllSupport(destnRoot, quiet)
%% Download pmtkSupport packages from pmtkSupport.googlecode.com

% This file is from pmtk3.googlecode.com


SetDefaultValue(1, 'destnRoot', fullfile(pmtk3Root(), 'pmtksupportCopy'));
SetDefaultValue(2, 'quiet', false);

fprintf('downloading packages to pmtk3/pmtksupportCopy from github - this may take a few minutes\n');
githubUrl = 'https://github.com/probml/pmtksupport/archive/master.zip';
temporaryZipFile = strcat(destnRoot, 'temp.zip');
[f, success] = urlwrite(githubUrl, temporaryZipFile);
if success
    unzip(temporaryZipFile, destnRoot);
    delete(temporaryZipFile);
    movefile(strcat(destnRoot, '/pmtksupport-master/*'), destnRoot);
    rmdir(strcat(destnRoot, '/pmtksupport-master'));
elseif ~quiet 
    fprintf(2, 'failed to download\n');  
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
