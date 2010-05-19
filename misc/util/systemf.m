function [status, result] = systemf(command,varargin)
% Just like built in system but allows sprintf syntax
    [status, result] = system(sprintf(command,varargin{:}));
end