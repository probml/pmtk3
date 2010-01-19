function args = addArgs(args,varargin)
    args(end+1:end+numel(varargin)) = varargin;
end