function s = createStruct(names, values)
%% Create a struct from two separate lists: names, and values.
% Usually to create a struct you have to interleave the names and values
% as in struct('name1',val1,'name2',val2,...) - here you can pass in the
% names and values as two cell arrays. If values is not specified, it just
% assigns {}.

% This file is from pmtk3.googlecode.com

s = struct;
if(nargin < 2)
    for i=1:numel(names);
        s.(names{i}) = {};
    end
else
    if(isnumeric(values))
        values = num2cell(values);
    end
    for i=1:numel(names);
        s.(names{i}) = values{i};
    end 
end
end
