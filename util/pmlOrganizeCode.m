function [missing, extra, copyProblems] = pmlOrganizeCode(bookSource, dest, demosOnly, includeCodeSol)
% Organize the PMTK code files referenced in PML into folders according to
% the chapter in which they are referenced. If a file is referenced in
% more than one chapter, the first chapter is used unless this is chapter
% 1, the introduction. Files are copied, not moved.
%
%% Input
%
% bookSource     - path to the PML latex source containing e.g. pml.tex
%                 (default = C:\kmurphy\local\PML\Text)
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
% missing        - a cell array of the code files referenced in PML that
%                  are not on the Matlab path.
%
% extra          - a cell array of the demo files not referenced in PML
%
% copyProblems   - a cell array of the files that could not be copied
%% Set Defaults
SetDefaultValue(1, 'bookSource', 'C:\kmurphy\local\PML\Text');
SetDefaultValue(2, 'dest',  'C:\users\matt\Desktop\PMLcode');
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
chname = processChapterNames(chname);
[pmlCode, pg] = pmlCodeRefs(codeIndFile);
%% Remove built in functions
pmlCode = pmlCode(~isbuiltin(pmlCode)); 
%%
nchapters     = numel(chpg);
[pmlCode, missing, foundNdx] = partitionCell(...
    pmlCode, (@(c)exist(c, 'file') > 0));
pg(~foundNdx) = [];
ch = zeros(numel(pmlCode), 1);
for i=1:numel(pmlCode)
    ch(i) = getChapter(chpg, pg{i});
    assert(ch(i) ~= 0);
end
%% Create destination directory structure
if ~exist(dest, 'file')
   system(sprintf('md "%s"', dest)); 
end
for i=1:nchapters
    directory = fullfile(dest, sprintf('ch%d %s', i, chname{i}));
    if ~exist(directory, 'file')
        system(sprintf('md "%s"', directory));
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
    d = fullfile(dest, sprintf('ch%d %s', chapter, chname{chapter}));
    err = system(sprintf('copy "%s" "%s"', which(file), d));
    if err
        copyProblems = insertEnd(file, copyProblems);
    end
    if ~exist(fullfile(dest, 'extra'), 'file')
        system(sprintf('md "%s"', (fullfile(dest, 'extra'))));
    end
end
for i=1:numel(extra)
    err = system(sprintf('copy "%s" %s"', which(extra{i}),  fullfile(dest, 'extra')));
    if err
        copyProblems = insertEnd(extra{i}, copyProblems);
    end
end

%% Check that we have accounted for all of the demos
copiedFiles = cellfuncell(@(c)c(1:end-2), mfiles(dest));
assert(isequal(sort(copiedFiles), sort(PMTKdemos)));

%%
end



function ch = getChapter(chpg, pg)
% Given a list of the chapter starting pages, and a list of page numbers,
% return a representative chapter. If the pages are from different
% chapters, select the first, (unless this is chapter 1).
chaps = zeros(numel(pg), 1);
for i=1:numel(pg)
    chaps(i) = sum(pg(i) >= chpg);
end
chaps = unique(chaps);
if numel(chaps) == 1
    ch = chaps;
elseif chaps(1) == 1
    ch = chaps(2);
else
    ch = chaps(1);
end


end


function chname = processChapterNames(chname)
% make sure the chapter names are valid directory names
chname = cellfuncell(@(c)regexprep(c, '[,()\[\]:;&%$#@!`?]', ''), chname);
chname = cellfuncell(@(c)strrep(strtrim(c), '  ', ' '), chname);
end