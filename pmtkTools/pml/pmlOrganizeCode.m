function [missing, extra, copyProblems, missingExtra] = pmlOrganizeCode(bookSource, dest, demosOnly, includeCodeSol)
% Organize the PMTK code files referenced in PML into folders 
% according to the chapter in which they are referenced. If a file is
% referenced in more than one chapter, the first chapter is used unless
% this is chapter 1, the introduction. Files are copied, not moved. 
%
%% Input
%
% bookSource     - path to the PML latex source containing e.g. pml.tex
%                 (default = C:\kmurphy\dropbox\PML\Text)
%
% dest           - destination for the copied files
%                  (default = 'C:\users\matt\Desktop\PMLcode')
%
% demosOnly      - if true, (default) only demos are copied
%
% includeCodeSol - if true, (default = false) the following command is run
%                  first:
%                  addpath(genpath(fullfile(bookSource, '..', 'CodeSol')), '-end')
%                  i.e. the CodeSol directory is added to the MATLAB path.
%
%% Output
%
% If you only want a report of missing or extra files use
% pmlMissingCodeReport() or pmlUnusedDemoReport() instead. 
% 
% missing        - a cell array of the code files referenced in PML that
%                  are not on the Matlab path.
%
% extra          - a cell array of the demo files not referenced in PML at
%                  all, not even in an \extraCode ref
%
% copyProblems   - a cell array of the files that could not be copied
%
% missingExtra   - a cell array of files with \extraCode refs in pml that
%                  cannot be found. 
%% Set Defaults

% This file is from pmtk3.googlecode.com

SetDefaultValue(1, 'bookSource', getConfigValue('PMTKpmlBookSource'));
%SetDefaultValue(1, 'bookSource', 'C:\Users\matt\Desktop\may1backup'); 
%SetDefaultValue(2, 'dest',  'C:\users\matt\Desktop\PMLcode');
SetDefaultValue(2, 'dest',  '/Users/Matt/Desktop/organizedDemos');
SetDefaultValue(3, 'demosOnly', true);
SetDefaultValue(4, 'includeCodeSol', false);
%% Optionally add CodeSol to path
if includeCodeSol
    addpath(genpath(fullfile(bookSource, '..', 'CodeSol')), '-end')
end
%% Parse latex toc and ind files
tocfile       = fullfile(bookSource, 'pml.toc');
codeIndFile   = fullfile(bookSource, 'code.ind');
[chpg, chname]= pmlChapterPages(tocfile);
chname = pmlProcessChapterNames(chname);
[pmlCode, pg] = pmlCodeRefs(codeIndFile);
%% Remove built in functions
notBuiltin = ~isbuiltin(pmlCode);
pmlCode = pmlCode(notBuiltin); 
pg = pg(notBuiltin); 

%%
nchapters     = numel(chpg);
[pmlCode, missing, foundNdx] = partitionCell(...
    pmlCode, (@(c)exist(c, 'file') > 0));
pg(~foundNdx) = [];
ch = zeros(numel(pmlCode), 1);
for i=1:numel(pmlCode)
    ch(i) = pmlGetChapter(chpg, pg{i});
    assert(ch(i) ~= 0);
end
%% Create destination directory structure
if ~exist(dest, 'file')
   system(sprintf('mkdir "%s"', dest)); 
end
for i=1:nchapters
    directory = fullfile(dest, sprintf('(%d)-%s',i, chname{i}));
    if ~exist(directory, 'file')
        system(sprintf('mkdir "%s"', directory));
    end
end
%% Get a list of all PMTK demo files
PMTKdemos = cellfuncell(@(c)c(1:end-2), mfiles(fullfile(pmtk3Root(), 'demos')));
%% Find out which demos are not included in PML
extra = setdiff(PMTKdemos, pmlCode);
%% Copy the files
copyProblems = {};
for i=1:numel(pmlCode)
    file = pmlCode{i};
    chapter = ch(i);
    if demosOnly && ~ismember(file, PMTKdemos)
        continue
    end
    d = fullfile(dest, sprintf('(%d)-%s',chapter, chname{chapter}));
    err = system(sprintf('cp "%s" "%s"', which(file), d));
    if err
        copyProblems = insertEnd(file, copyProblems);
    end
    if ~exist(fullfile(dest, 'extra'), 'file')
        system(sprintf('mkdir "%s"', (fullfile(dest, 'extra'))));
    end
end
for i=1:numel(extra)
    err = system(sprintf('cp "%s" "%s"', which(extra{i}),  fullfile(dest, 'extra')));
    if err
        copyProblems = insertEnd(extra{i}, copyProblems);
    end
end




%%
%% Organize the extra files (now turned off)
%[missingExtra, extra] = pmlMoveExtraCode(bookSource, dest); 
missingExtra = [];
%% Check that we have accounted for all of the demos
copiedFiles = cellfuncell(@(c)c(1:end-2), mfiles(dest));
assert(isequal(sort(copiedFiles), sort(PMTKdemos)));

%%
end





