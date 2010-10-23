function [status, result] = systemf(command,varargin)
% Just like built in system but allows sprintf syntax

% This file is from matlabtools.googlecode.com

    [status, result] = system(sprintf(command,varargin{:}));
end
