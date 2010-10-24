function v = collapseCell(c)
% Collapse a nested cell array as much as possible
%
% Example:
% collapseCell({1,2,3,{4,5,6,{7,8,9,{10,11,12}}},13,14,{15,16,{17,18,19}}})'
%ans =
%     1     2     3     4     5     6     7     8     9    10    11    12    13    14    15    16    17    18    19

% This file is from pmtk3.googlecode.com


if ~iscell(c),v = c; return; end
if cellDepth(c) < 2
    v = colvec(cell2mat(cellfuncell(@colvec,c)));
else
    v = cellValues(colvec(cellfuncell(@cellValues,c)));
end
end
