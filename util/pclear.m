function pclear(nsecs)
    
if(nargin == 0)
    nsecs = 1;
end
pause(nsecs);
clear;
close all;
evalin('base','clear');
end