function [missing, extra] = pmlMoveExtraCode(bookSource, demosDir)
% Allocate code in demos/extra to the various chapters 
% according to the pml latex extraCode index. 
%
%% Inputs
%  bookSource    - path to the PML latex source containing e.g. pml.tex
%                 (default = C:\kmurphy\dropbox\PML\Text)
%
%  demosDir      - e.g. fullfile(pmtk3Root(), 'demos') but
%                  it is a good idea to run this on the copied 
%                  directory structure created by pmlOrganizeCode()
%
%% Outputs
%
% missing        - a cell array of the demos refereneced as extraCode
%                  that could not be found in the main extra directory
% 
% extra          - a list of the extra demos that were not allocated to 
%                  chapters
%
%%

% This file is from pmtk3.googlecode.com


SetDefaultValue(1, 'bookSource', getConfigValue('PMTKpmlBookSource'));
SetDefaultValue(2, 'demosDir', 'C:\users\matt\Desktop\PMLcode');

indexFile = fullfile(bookSource, 'extraCode.ind'); 
[pmlCode, pg] = pmlCodeRefs(indexFile);

tocfile        = fullfile(bookSource, 'pml.toc');
[chpg, chname] = pmlChapterPages(tocfile);
chname         = pmlProcessChapterNames(chname);
%%
currentExtra   = mfiles(fullfile(demosDir, 'extra'), 'removeExt', true); 
missing = setdiff(pmlCode, currentExtra); 
extra   = setdiff(currentExtra, pmlCode); 
[tomove, idx] = setdiff(pmlCode, missing); 
pg = pg(idx); 
assert(numel(pg) == numel(tomove)); 
%%
for i=1:numel(tomove)
    source = [fullfile(demosDir, 'extra', tomove{i}),'.m']; 
    dest   = fullfile(demosDir, chname{pmlGetChapter(chpg, pg{i})}, 'extra');
    if ~exist(dest, 'file')
        mkdir(dest);
    end
    movefile(source, dest);
    
end



end



