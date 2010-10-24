function a = sub(b, ndx)
% Subscript the return value of a function directly
% without first storing the result. e.g. mean(rand(10),2)(3) is not allowed
% in matlab you have to go tmp = mean(rand(10),2); result = tmp(3); With
% this function, you can go sub(mean(rand(10),2),3). Use subc for {}
% indexing.

% This file is from pmtk3.googlecode.com

if isempty(b)
    a = []; return;
end
if(ischar(ndx))
    a = eval(['b(',ndx,')']);
else
    a = b(ndx);
end
end
