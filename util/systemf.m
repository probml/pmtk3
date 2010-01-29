function [result, success] = systemf(command,varargin)
% Just like built in system but allows sprintf syntax, reverses output
% order so that result comes first, and return true if the command was
% successful rather than 0 as system does. 
    [status, result] = system(sprintf(command,varargin{:}));
    success = status == 0;
end