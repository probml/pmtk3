function h = horizontalLine(yloc, varargin)
% Draws a horizontal line at the specified yloc on the current axes. All 
% additional args are passed directly to the line function. 

% This file is from pmtk3.googlecode.com

    a = axis();
    h = line([a(1), a(2)], [yloc, yloc], varargin{:}); 

end
