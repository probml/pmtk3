function [pg, name] = pmlChapterPages(tocfile)
% Return a list of the starting, (hard cover) pages of the chapters in PML. 
% (skips the preface so that pg(1) = 1, not e.g. xxv)
%% Input
% tocfile - the path to the pml.toc file
% (default = C:\kmurphy\local\PML\Text\pml.toc)
%
%% Output
%
% pg   - a list of the starting pages for each chapter
% name - the name of the chapter, e.g. "Introduction", "The multivariate
% Gaussian", etc. 

% This file is from pmtk3.googlecode.com


if nargin == 0
    tocfile = fullfile(getConfigValue('PMTKpmlBookSource'), 'pml.toc');
end

if ~exist(tocfile, 'file')
    error('Could not find %s, check the path and try recompiling the latex source.', tocfile); 
end

text = getText(tocfile); 
text = filterCell(text, @(c)isSubstring('{chapter}', c));
if isSubstring('{Preface}', text{1});
    text(1) = [];
end
text(end) = []; %bibliography
nchapters = numel(text);
pg = zeros(nchapters, 1);
name = cell(nchapters, 1);
for i=1:nchapters 
   toks = tokenize(text{i}, '{}');
   toks = removeEmpty(toks); 
   assert(str2num(toks{4}) == i);
   name{i} = toks{5};
   pg(i) = str2num(toks{6});
end


end
