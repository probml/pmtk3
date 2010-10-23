function out = dots(n)
% Print n dots to the console

% This file is from matlabtools.googlecode.com

if nargout > 0
    out = sprintf('%s', repmat('.', 1,n));
else
    fprintf('%s', repmat('.', 1,n))
end
end
