function pclear(nsecs)
% Used by runDemos - pause for nsecs and then clear and close figures    

% This file is from pmtk3.googlecode.com

if(nargin == 0)
    nsecs = 1;
end
pause(nsecs);
clear;
close all;
evalin('base','clear');
end
