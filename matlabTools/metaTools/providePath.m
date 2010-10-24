function providePath(p)
% Like builtin addpath function, but checks if p is already on the path
% and does nothing if it is, (rather than issue a warning as addpath does).

% This file is from pmtk3.googlecode.com

    
    if ischar(p)
        p = tokenize(p, ';');
    end
    for i=1:numel(p)
        if ~onMatlabPath(p{i})
            addpath(p{i})
        end
    end
end
