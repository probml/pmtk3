function d = cellDepth(c)
% Determine the maximum depth of a nested cell array
% cellDepth({})
% ans =
%      0
% cellDepth({{}})
% ans =
%      1
% cellDepth({{{}}})
% ans =
%      2
% cellDepth({{{{}}}})
% ans =
%      3

% This file is from pmtk3.googlecode.com


if isempty(c) || ~iscell(c),
    d = 0;
else
    d = 1 + max(unwrapCell(cellfuncell(@cellDepth,c)));
end


end
