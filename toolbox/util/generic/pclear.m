function pclear(nsecs)
% Used by runDemos - pause for nsecs and then clear and close figures    
if(nargin == 0)
    nsecs = 1;
end
pause(nsecs);
clear;
close all;
evalin('base','clear');
end