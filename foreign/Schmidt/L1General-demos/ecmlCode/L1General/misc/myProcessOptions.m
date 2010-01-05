function [varargout] = myProcessOptions(options,varargin)
% Similar to processOptions, but using a struct instead
% of a variable length list

for i = 1:2:length(varargin)
    if isfield(options,varargin{i})
        if isempty(getfield(options,varargin{i}))
            varargout{(i+1)/2}=varargin{i+1};
        else
            varargout{(i+1)/2}=getfield(options,varargin{i});;
        end
    else
        varargout{(i+1)/2}=varargin{i+1};
    end
end