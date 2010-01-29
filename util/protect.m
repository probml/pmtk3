function func = protect(varargin)
% Takes in a function handle and returns a protected version that when
% executed, returns the default value whenever guard(input) is true and
% otherwise evaluates normally. The default guard is @isempty and the
% default value is 0. 


% Example:
% cellfun(@mean,{ {}, 1:10, 2:20, 3:30, {} };  % this will fail because of the empty cells
% cellfun(protect(@mean),{ {}, 1:10, 2:20, 3:30, {} })
% ans =
%         0    5.5000   11.0000   16.5000         0

    [fn,default,guard] = processArgs(varargin,'*+-func',@(x)x,'-default',0,'+-guard',@isempty);
    function out = wrapper(in)
        if guard(in)
            out = default;
        else
            out = fn(in);
        end
    end
    func = @wrapper;
end


