function s = createStruct(names,values)
 % usually to create a struct you have to interleave the names and values like
 % struct('name1',val1,'name2',val2,...) - here you can pass in the names and
 % values as two cell arrays. If values is not specified, it just assigns {}.
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