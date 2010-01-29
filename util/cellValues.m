function v = cellValues(c)
% Return all the cell values in one big numeric array
%
% Example:
% cellValues({1,2,3,{4,5,6,{7,8,9,{10,11,12}}},13,14,{15,16,{17,18,19}}})'
%ans =
%     1     2     3     4     5     6     7     8     9    10    11    12    13    14    15    16    17    18    19

   if ~iscell(c),v = c; return; end
   if cellDepth(c) < 2
       v = colvec(cell2mat(cellfuncell(@colvec,c)));
   else 
       v = cellValues(colvec(cellfuncell(@cellValues,c)));
   end
end