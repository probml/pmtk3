function [status, result] = systemf(command,varargin)
% Just like built in system but allows sprintf syntax

% This file is from pmtk3.googlecode.com

    [status, result] = system(sprintf(command,varargin{:}));
end
