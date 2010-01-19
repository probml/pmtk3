function tf = boolValue(v)
    
    if nargin == 0 || isempty(v)      ; tf = false; return; end
    if iscell(v)                      ; tf = boolValue(unwrapCell(v)); return; end
    if ~islogical(v) && ~isnumeric(v) ; tf = false; return; end
                                        tf = all(logical(v));
end