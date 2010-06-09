function d = datestring()
%% Return a string name based on the current date and time
d = datestr(now); d(d ==':') = '_'; d(d == ' ') = '_'; d(d=='-') = [];
end