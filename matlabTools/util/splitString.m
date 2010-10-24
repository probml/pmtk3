function S = splitString(varargin)
% Split a string into multiple lines based on camel case
%
% Inputs
%
% '-S'          the string to split
% '-minSize'    does not split at all if length(S) < minSize
% '-maxSize'    splits no matter what, (even if no camel case change) if length(S) > maxSize
% '-center'     if true, [default], the string is center justified 
% '-cellMode'   if true, a cell array of strings is returned, instead of a char array.

% This file is from pmtk3.googlecode.com


    [S,minSize,maxSize,cellMode,center] = process_options(varargin,'S','','minSize',8,'maxSize',10,'cellMode',false,'center',true);

    S = splitInTwo(S);
    if center
        S = strjust(S,'center');
    end
    if cellMode
       S =  cellstr(S);
    end
    
    
    
    function str = splitInTwo(str)
    % recursively split a string into two based on camel case
        isupper = isstrprop(str(2:end),'upper');
        if(size(str,2) >= minSize && any(isupper))
            first = find(isupper); first = first(1);
            top = str(1:first);
            bottom = str(first+1:end);
            str = strvcat(splitInTwo(top),splitInTwo(bottom)); %#ok
        elseif(size(str,2) > maxSize)
            top = [str(1:floor(length(str)/2)),'-'];
            bottom = str(floor(length(str)/2)+1:end);
            str = strvcat(splitInTwo(top),splitInTwo(bottom)); %#ok
        end
    end
    
    
    
    
    
    
end
