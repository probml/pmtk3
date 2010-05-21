function [varargout] = myProcessOptions(options,varargin)
% Similar to processOptions, but case insensitive and
%   using a struct instead of a variable length list

options = toUpper(options);

for i = 1:2:length(varargin)
    if isfield(options,upper(varargin{i}))
        v = getfield(options,upper(varargin{i}));
        if isempty(v)
            varargout{(i+1)/2}=varargin{i+1};
        else
            varargout{(i+1)/2}=v;
        end
    else
        varargout{(i+1)/2}=varargin{i+1};
    end
end

end

function [o] = toUpper(o)
if ~isempty(o)
    fn = fieldnames(o);
    for i = 1:length(fn)
        o = setfield(o,upper(fn{i}),getfield(o,fn{i}));
    end
end
end