function func = protect(varargin)
% Wrap a function handle guarding against a specific value, e.g. []
% Takes in a function handle and returns a protected version that when
% executed, returns the default value whenever guard(input) is true and
% otherwise evaluates normally. The default guard is @isempty and the
% default value is 0.

% This file is from pmtk3.googlecode.com



% Example:
% cellfun(@mean,{ {}, 1:10, 2:20, 3:30, {} };  % this will fail because of the empty cells
% cellfun(protect(@mean),{ {}, 1:10, 2:20, 3:30, {} })
% ans =
%         0    5.5000   11.0000   16.5000         0

[fn,default,guard] = process_options(varargin,'*func',@(x)x,'default',0,'guard',@isempty);
    function out = wrapper(in)
        if guard(in)
            out = default;
        else
            out = fn(in);
        end
    end
func = @wrapper;
end


