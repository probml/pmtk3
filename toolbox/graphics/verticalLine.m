function h = verticalLine(xloc, varargin)
% Draws a vertical line at the specified xloc on the current axes. All 
% additional args are passed directly to the line function. 
    a = axis();
    h = line([xloc, xloc], [a(3), a(4)], varargin{:}); 

end