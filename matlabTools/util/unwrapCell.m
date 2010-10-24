function M = unwrapCell(C)
% Recursively remove superfluous cell nestings and eventually concatinate
% using cell2mat. This is an idempotent operation; calling it on a cell 
% array that cannot be unwrapped any further returns the orginal cell 
% array, unaltered. Full unwrapping, (using cell2mat concatination) only 
% applies to cell array nestings whose values are numeric. Other types, 
% i.e. objects, strings, etc, are never concatinated, but unnecessary cell
% nestings are still removed. 
%
% Examples
% 
% unwrapCell({{{1}}})
% ans =
%      1
%
% unwrapCell({[1,2,3];[4,5,6]})
% ans =
%      1     2     3
%      4     5     6
%
%
% unwrapCell({1,2,3;4,5,6})
% ans =
%      1     2     3
%      4     5     6
%
% unwrapCell({{1},{2},{3};{4},{5},{6}})
% ans =
%      1     2     3
%      4     5     6
%
% unwrapCell({{{[1,2,3]}};{{[4,5,6]}}})
% ans =
%      1     2     3
%      4     5     6
%
% unwrapCell({{1,2},{3,4},{5,6};{7,8},{9,10},{11,12}})
% ans =
%      1     2     3     4     5     6
%      7     8     9    10    11    12
%
% unwrapCell({{[1,2]},{[3,4]},{[5,6]};{[7,8]},{[9,10]},{[11,12]}})
% ans =
%      1     2     3     4     5     6
%      7     8     9    10    11    12
%
% unwrapCell({{{MvnDist,MvnDist,MvnDist}};{{MvnDist,MvnDist,MvnDist}}})
% ans = 
%     {1x3 cell}
%     {1x3 cell}
%
% unwrapCell({{{{MvnDist},{MvnDist},{MvnDist}}};{{{MvnDist},{MvnDist},{MvnDist}}}})
%ans = 
%    {1x3 cell}
%    {1x3 cell}
%
% unwrapCell({{rand(5,7)},{rand(4,9)}})
% ans = 
%    [5x7 double]    [4x9 double]

% This file is from pmtk3.googlecode.com


if isempty(C), M = []; return; end
if ~iscell(C), M = C;  return; end
if numel(C) == 1, M = C{1}; return; end
if allSameTypes(C) && iscell(C{1}) && numel(C{1}) == 1
    M = unwrapCell(cellfuncell(@(a)a{1},C));
    return;
end
sizes = cellfun(@(a)numel(a),C);
if all(cellfun(@(a)isvector(a)&& numel(a)==sizes(1),C(:)))
    if all(cellfun(@(a)isnumeric(a),C))
        M = cell2mat(cellfuncell(@(a)rowvec(a),C));
    elseif all(cellfun(@(a)iscell(a),C))
        try
            T = unwrapCell(cellfuncell(@(a)cell2mat(a),C));
            if isnumeric(T)
                M = T;
            else
                M = C;
            end
        catch %#ok
            M = C;
        end
    else
        M = C;
    end
else
    M = C;
end
end
