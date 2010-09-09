function ch = pmlGetChapter(chpg, pg)
% Return the chapter name from which the specified page occurs
%
% Given a list of the chapter starting pages, and a list of page numbers,
% return a representative chapter. If the pages are from different
% chapters, select the first, (unless this is chapter 1).

% This file is from pmtk3.googlecode.com

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
