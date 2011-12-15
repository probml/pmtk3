function B = pmlGrabBook(includeEx, includeSol)
%% Grab the entire PML book and put it in a cell array 
% Each chapter is put in its own subcell so that B{i}{j} is the jth line in
% chapter i. Comments, (including block comments} and blank spaces are
% removed. Does not include, ttl, dummy, preface, or the generated indexes.
% 
%
%
% Ignores \includeonly and \includeversion latex commands
%
% if includeEx is true, the excerices, (if any) are appended to the chapter
% similarly for includeSol. 
%
% May include blank cells if a chapter was included but no text found. 
%
%
% 
% Assumptions
%
% Each included chapter is listed in order in pml.tex with \include{chname}
% Each chapter.tex file has \input{chbody} lines. 
% The book must be capable of being compiled, i.e. no syntax errors. 
% 
%%

% This file is from pmtk3.googlecode.com

if nargin  == 0 
    includeEx = false;
    includeSol = false; 
end
bookSource = getConfigValue('PMTKpmlBookSource');
chapterFiles = getChapterFileNames(fullfile(bookSource, 'pml.tex')); 
nchaps = numel(chapterFiles); 
B = cell(nchaps, 1); 
for i=1:nchaps
   B{i} = getChapterText(chapterFiles{i}, includeEx, includeSol);  
   %B{i} = processText(getText(chapterFiles{i}));
end
end

function T = getChapterText(chfile, includeEx, includeSol)
%% Return a chapter's full body text given the parent chapter filename
% Removes comments and blanks before returning
% parses fooChap.tex which is assumed to contain
%   \input{fooBody.tex}
%   \input{fooEx.tex}
%   \input{fooChap.tex}
% if includeEx is true, it appends the exercises
% if includSol is true, it appends the solutions
%%
inputStr = '\input'; 
ext = '.tex'; 
cT = processText(getText(chfile));
cT = cT(strncmpi(cT, inputStr, length(inputStr))); 
bodyFiles = cellfuncell(@(c)textBetween(c, '{', '}'), cT); 
bodyFiles = cellfuncell(@(c)fullfile(fileparts(chfile), [c, ext]), bodyFiles); 
if isempty(bodyFiles)
    T = {}; return;
end
T = getText(bodyFiles{1}); 
if includeEx && numel(bodyFiles) > 1
   T = [T; getText(bodyFiles{2})];  
end
if includeSol && numel(bodyFiles) > 2
    T = [T; getText(bodyFiles{3})];  
end
T = processText(T); 
end

function fnames = getChapterFileNames(pmlTexFile)
%% Return the filenames of all of the included chapter.tex files
% in the order in which they appear in pml.tex
ignoreList = {'ttl', 'dummy', 'preface', 'prefaceChap'}; 
includeStr = '\include';
%includeStr = '\input';
beginStr   = '\begin{document}'; 
ext        = '.tex';
T          = processText(getText(pmlTexFile)); 
T          = T(cellfind(T, beginStr)+1:end); 
includes   = T(strncmpi(T, includeStr, length(includeStr))); 
includes   = cellfuncell(@(c)textBetween(c, '{', '}'), includes);
for i=1:numel(ignoreList)
    includes(cellfind(includes, ignoreList{i})) = [];
end
fnames = cellfuncell(@(c)fullfile(fileparts(pmlTexFile), [c, ext]), includes); 
end

function T = processText(T)
%% Process latex text, removing blanks and comments. 
T = removeComments(T);
T = strtrim(T); 
T = removeBlockComments(T); 
end

function T = removeBlockComments(T)
%% Remove \begin{comment} blocks from a cell array of latex source
nlines = numel(T); 
keep = true(nlines, 1); 
commentMode = false; 
for i=1:nlines
    line = T{i}; 
    if commentMode
        keep(i) = false; 
        if startswith(line, '\end{comment}')
            commentMode = false;
        end
    else
        if startswith(line, '\begin{comment}')
            keep(i) = false; 
            commentMode = true;
        end
    end
end
T = T(keep); 
end
