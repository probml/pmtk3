function d = cellDepth(c)
% Indicates the maximum depth you need to go before you hit a value
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

    if isempty(c) || ~iscell(c), 
        d = 0; 
    else
        d = 1 + max(unwrapCell(cellfuncell(@cellDepth,c)));
    end
    
    
end