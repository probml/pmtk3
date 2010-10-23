function d = datestring()
%% Return a string name based on the current date and time

% This file is from matlabtools.googlecode.com

d = datestr(now); d(d ==':') = '_'; d(d == ' ') = '_'; d(d=='-') = [];
end
